//===- Trace.cpp - Simulation trace implementation ------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the Trace class, used to handle the signal trace
// generation for the llhd-sim tool.
//
//===----------------------------------------------------------------------===//

#include "circt/Dialect/LLHD/Simulator/Trace.h"
#include "llvm/Support/raw_ostream.h"

using namespace circt::llhd::sim;

Trace::Trace(std::unique_ptr<State> const &state, llvm::raw_ostream &out,
             TraceMode mode)
    : out(out), state(state), mode(mode) {
  auto root = state->getRoot();
  for (auto &sig : state->getSignals()) {
    bool done = (mode != TraceMode::Full && mode != TraceMode::Merged &&
                 !sig.isOwner(root)) ||
                (mode == TraceMode::NamedOnly && sig.isValidSigName());
    isTraced.push_back(!done);
  }
}

//===----------------------------------------------------------------------===//
// Changes gathering methods
//===----------------------------------------------------------------------===//

void Trace::pushChange(unsigned instIndex, unsigned sigIndex, int elem = -1) {
  auto &sig = state->getSignal(sigIndex);
  std::string valueDump;
  std::string path;
  llvm::raw_string_ostream ss(path);

  ss << state->getInstance(instIndex).getPath() << '/' << sig.getName();

  if (elem >= 0) {
    // Add element index to the hierarchical path.
    ss << '[' << elem << ']';
    // Get element value dump.
    valueDump = sig.toHexString(elem);
  } else {
    // Get signal value dump.
    valueDump = sig.toHexString();
  }

  // Check wheter we have an actual change from last value.
  auto lastValKey = std::make_pair(path, elem);
  if (valueDump != lastValue[lastValKey]) {
    changes.push_back(std::make_pair(path, valueDump));
    lastValue[lastValKey] = valueDump;
  }
}

void Trace::pushAllChanges(unsigned instIndex, unsigned sigIndex) {
  auto &sig = state->getSignal(sigIndex);
  if (sig.hasElement() > 0) {
    // Push changes for all signal elements.
    for (size_t i = 0, e = sig.getElementSize(); i < e; ++i) {
      pushChange(instIndex, sigIndex, i);
    }
  } else {
    // Push one change for the whole signal.
    pushChange(instIndex, sigIndex);
  }
}

void Trace::addChange(unsigned sigIndex) {
  if (mode == TraceMode::None)
    return;

  currentTime = state->getTime();
  if (isTraced[sigIndex]) {
    if (mode == TraceMode::Full) {
      auto &sig = state->getSignal(sigIndex);
      // Add a change for each connected instance.
      for (auto ii : sig.getTriggeredInstanceIndices()) {
        pushAllChanges(ii, sigIndex);
      }
    } else if (mode == TraceMode::Reduced) {
      // The root is always the last instance in the instances list.
      pushAllChanges(state->getInstanceSize() - 1, sigIndex);
    } else if (mode == TraceMode::Merged || mode == TraceMode::MergedReduce ||
               mode == TraceMode::NamedOnly) {
      addChangeMerged(sigIndex);
    }
  }
}

void Trace::addChangeMerged(unsigned sigIndex) {
  auto &sig = state->getSignal(sigIndex);
  if (sig.getElementSize() > 0) {
    // Add a change for all sub-elements
    for (size_t i = 0, e = sig.getElementSize(); i < e; ++i) {
      auto valueDump = sig.toHexString(i);
      mergedChanges[std::make_pair(sigIndex, i)] = valueDump;
    }
  } else {
    // Add one change for the whole signal.
    auto valueDump = sig.toHexString();
    mergedChanges[std::make_pair(sigIndex, -1)] = valueDump;
  }
}

//===----------------------------------------------------------------------===//
// Flush methods
//===----------------------------------------------------------------------===//

void Trace::sortChanges() {
  std::sort(changes.begin(), changes.end(),
            [](std::pair<std::string, std::string> &lhs,
               std::pair<std::string, std::string> &rhs) -> bool {
              return lhs.first < rhs.first;
            });
}

void Trace::flush(bool force) {
  if (mode == TraceMode::None)
    return;
  else if (mode == TraceMode::Full || mode == TraceMode::Reduced)
    flushFull();
  else if (mode == TraceMode::Merged || mode == TraceMode::MergedReduce ||
           mode == TraceMode::NamedOnly)
    if (state->getTime().getTime() > currentTime.getTime() || force)
      flushMerged();
}

void Trace::flushFull() {
  if (changes.size() > 0) {
    sortChanges();

    auto timeStr = currentTime.toString();
    for (auto change : changes) {
      out << timeStr << "  " << change.first << "  " << change.second << "\n";
    }
    changes.clear();
  }
}

void Trace::flushMerged() {
  // Move the merged changes to the changes vector for dumping.
  for (auto elem : mergedChanges) {
    auto sigIndex = elem.first.first;
    auto sigElem = elem.first.second;
    auto &sig = state->getSignal(sigIndex);
    auto change = elem.second;

    if (mode == TraceMode::Merged) {
      // Add the changes for all connected instances.
      for (auto ii : sig.getTriggeredInstanceIndices()) {
        pushChange(ii, sigIndex, sigElem);
      }
    } else {
      // The root is always the last instance in the instances list.
      pushChange(state->getInstanceSize() - 1, sigIndex, sigElem);
    }
  }

  if (changes.size() > 0) {
    sortChanges();

    // Flush the changes to output stream.
    out << currentTime.getTime() << "ps\n";
    for (auto change : changes) {
      out << "  " << change.first << "  " << change.second << "\n";
    }
    mergedChanges.clear();
    changes.clear();
  }
}
