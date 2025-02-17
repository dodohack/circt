// NOTE: Assertions have been autogenerated by utils/update_mlir_test_checks.py
// RUN: circt-opt -lower-std-to-handshake %s | FileCheck %s
// CHECK-LABEL:   handshake.func @affine_apply_loops_shorthand(
// CHECK-SAME:                                                 %[[VAL_0:.*]]: index,
// CHECK-SAME:                                                 %[[VAL_1:.*]]: none, ...) -> none attributes {argNames = ["in0", "inCtrl"], resNames = ["outCtrl"]} {
// CHECK:           %[[VAL_2:.*]] = merge %[[VAL_0]] : index
// CHECK:           %[[VAL_3:.*]]:3 = fork [3] %[[VAL_1]] : none
// CHECK:           %[[VAL_4:.*]] = constant %[[VAL_3]]#1 {value = 0 : index} : index
// CHECK:           %[[VAL_5:.*]] = constant %[[VAL_3]]#0 {value = 1 : index} : index
// CHECK:           %[[VAL_6:.*]] = br %[[VAL_2]] : index
// CHECK:           %[[VAL_7:.*]] = br %[[VAL_3]]#2 : none
// CHECK:           %[[VAL_8:.*]] = br %[[VAL_4]] : index
// CHECK:           %[[VAL_9:.*]] = br %[[VAL_5]] : index
// CHECK:           %[[VAL_10:.*]], %[[VAL_11:.*]] = control_merge %[[VAL_7]] : none
// CHECK:           %[[VAL_12:.*]]:3 = fork [3] %[[VAL_11]] : index
// CHECK:           %[[VAL_13:.*]] = buffer [1] %[[VAL_14:.*]] {initValues = [0], sequential = true} : i1
// CHECK:           %[[VAL_15:.*]]:4 = fork [4] %[[VAL_13]] : i1
// CHECK:           %[[VAL_16:.*]] = mux %[[VAL_15]]#3 {{\[}}%[[VAL_10]], %[[VAL_17:.*]]] : i1, none
// CHECK:           %[[VAL_18:.*]] = mux %[[VAL_12]]#2 {{\[}}%[[VAL_6]]] : index, index
// CHECK:           %[[VAL_19:.*]] = mux %[[VAL_15]]#2 {{\[}}%[[VAL_18]], %[[VAL_20:.*]]] : i1, index
// CHECK:           %[[VAL_21:.*]]:2 = fork [2] %[[VAL_19]] : index
// CHECK:           %[[VAL_22:.*]] = mux %[[VAL_12]]#1 {{\[}}%[[VAL_9]]] : index, index
// CHECK:           %[[VAL_23:.*]] = mux %[[VAL_15]]#1 {{\[}}%[[VAL_22]], %[[VAL_24:.*]]] : i1, index
// CHECK:           %[[VAL_25:.*]] = mux %[[VAL_12]]#0 {{\[}}%[[VAL_8]]] : index, index
// CHECK:           %[[VAL_26:.*]] = mux %[[VAL_15]]#0 {{\[}}%[[VAL_25]], %[[VAL_27:.*]]] : i1, index
// CHECK:           %[[VAL_28:.*]]:2 = fork [2] %[[VAL_26]] : index
// CHECK:           %[[VAL_14]] = merge %[[VAL_29:.*]]#0 : i1
// CHECK:           %[[VAL_30:.*]] = arith.cmpi slt, %[[VAL_28]]#0, %[[VAL_21]]#0 : index
// CHECK:           %[[VAL_29]]:5 = fork [5] %[[VAL_30]] : i1
// CHECK:           %[[VAL_31:.*]], %[[VAL_32:.*]] = cond_br %[[VAL_29]]#4, %[[VAL_21]]#1 : index
// CHECK:           sink %[[VAL_32]] : index
// CHECK:           %[[VAL_33:.*]], %[[VAL_34:.*]] = cond_br %[[VAL_29]]#3, %[[VAL_23]] : index
// CHECK:           sink %[[VAL_34]] : index
// CHECK:           %[[VAL_35:.*]], %[[VAL_36:.*]] = cond_br %[[VAL_29]]#2, %[[VAL_16]] : none
// CHECK:           %[[VAL_37:.*]], %[[VAL_38:.*]] = cond_br %[[VAL_29]]#1, %[[VAL_28]]#1 : index
// CHECK:           sink %[[VAL_38]] : index
// CHECK:           %[[VAL_39:.*]] = merge %[[VAL_37]] : index
// CHECK:           %[[VAL_40:.*]]:2 = fork [2] %[[VAL_39]] : index
// CHECK:           %[[VAL_41:.*]] = merge %[[VAL_33]] : index
// CHECK:           %[[VAL_42:.*]] = merge %[[VAL_31]] : index
// CHECK:           %[[VAL_43:.*]], %[[VAL_44:.*]] = control_merge %[[VAL_35]] : none
// CHECK:           %[[VAL_45:.*]]:3 = fork [3] %[[VAL_43]] : none
// CHECK:           sink %[[VAL_44]] : index
// CHECK:           %[[VAL_46:.*]] = constant %[[VAL_45]]#1 {value = 42 : index} : index
// CHECK:           %[[VAL_47:.*]] = constant %[[VAL_45]]#0 {value = 1 : index} : index
// CHECK:           %[[VAL_48:.*]] = br %[[VAL_40]]#1 : index
// CHECK:           %[[VAL_49:.*]] = br %[[VAL_40]]#0 : index
// CHECK:           %[[VAL_50:.*]] = br %[[VAL_41]] : index
// CHECK:           %[[VAL_51:.*]] = br %[[VAL_42]] : index
// CHECK:           %[[VAL_52:.*]] = br %[[VAL_45]]#2 : none
// CHECK:           %[[VAL_53:.*]] = br %[[VAL_46]] : index
// CHECK:           %[[VAL_54:.*]] = br %[[VAL_47]] : index
// CHECK:           %[[VAL_55:.*]] = mux %[[VAL_56:.*]]#5 {{\[}}%[[VAL_57:.*]], %[[VAL_53]]] : index, index
// CHECK:           %[[VAL_58:.*]]:2 = fork [2] %[[VAL_55]] : index
// CHECK:           %[[VAL_59:.*]] = mux %[[VAL_56]]#4 {{\[}}%[[VAL_60:.*]], %[[VAL_54]]] : index, index
// CHECK:           %[[VAL_61:.*]] = mux %[[VAL_56]]#3 {{\[}}%[[VAL_62:.*]], %[[VAL_49]]] : index, index
// CHECK:           %[[VAL_63:.*]] = mux %[[VAL_56]]#2 {{\[}}%[[VAL_64:.*]], %[[VAL_50]]] : index, index
// CHECK:           %[[VAL_65:.*]] = mux %[[VAL_56]]#1 {{\[}}%[[VAL_66:.*]], %[[VAL_51]]] : index, index
// CHECK:           %[[VAL_67:.*]], %[[VAL_68:.*]] = control_merge %[[VAL_69:.*]], %[[VAL_52]] : none
// CHECK:           %[[VAL_56]]:6 = fork [6] %[[VAL_68]] : index
// CHECK:           %[[VAL_70:.*]] = mux %[[VAL_56]]#0 {{\[}}%[[VAL_71:.*]], %[[VAL_48]]] : index, index
// CHECK:           %[[VAL_72:.*]]:2 = fork [2] %[[VAL_70]] : index
// CHECK:           %[[VAL_73:.*]] = arith.cmpi slt, %[[VAL_72]]#1, %[[VAL_58]]#1 : index
// CHECK:           %[[VAL_74:.*]]:7 = fork [7] %[[VAL_73]] : i1
// CHECK:           %[[VAL_75:.*]], %[[VAL_76:.*]] = cond_br %[[VAL_74]]#6, %[[VAL_58]]#0 : index
// CHECK:           sink %[[VAL_76]] : index
// CHECK:           %[[VAL_77:.*]], %[[VAL_78:.*]] = cond_br %[[VAL_74]]#5, %[[VAL_59]] : index
// CHECK:           sink %[[VAL_78]] : index
// CHECK:           %[[VAL_79:.*]], %[[VAL_80:.*]] = cond_br %[[VAL_74]]#4, %[[VAL_61]] : index
// CHECK:           %[[VAL_81:.*]], %[[VAL_82:.*]] = cond_br %[[VAL_74]]#3, %[[VAL_63]] : index
// CHECK:           %[[VAL_83:.*]], %[[VAL_84:.*]] = cond_br %[[VAL_74]]#2, %[[VAL_65]] : index
// CHECK:           %[[VAL_85:.*]], %[[VAL_86:.*]] = cond_br %[[VAL_74]]#1, %[[VAL_67]] : none
// CHECK:           %[[VAL_87:.*]], %[[VAL_88:.*]] = cond_br %[[VAL_74]]#0, %[[VAL_72]]#0 : index
// CHECK:           sink %[[VAL_88]] : index
// CHECK:           %[[VAL_89:.*]] = merge %[[VAL_87]] : index
// CHECK:           %[[VAL_90:.*]] = merge %[[VAL_77]] : index
// CHECK:           %[[VAL_91:.*]]:2 = fork [2] %[[VAL_90]] : index
// CHECK:           %[[VAL_92:.*]] = merge %[[VAL_75]] : index
// CHECK:           %[[VAL_93:.*]] = merge %[[VAL_79]] : index
// CHECK:           %[[VAL_94:.*]] = merge %[[VAL_81]] : index
// CHECK:           %[[VAL_95:.*]] = merge %[[VAL_83]] : index
// CHECK:           %[[VAL_96:.*]], %[[VAL_97:.*]] = control_merge %[[VAL_85]] : none
// CHECK:           sink %[[VAL_97]] : index
// CHECK:           %[[VAL_98:.*]] = arith.addi %[[VAL_89]], %[[VAL_91]]#1 : index
// CHECK:           %[[VAL_60]] = br %[[VAL_91]]#0 : index
// CHECK:           %[[VAL_57]] = br %[[VAL_92]] : index
// CHECK:           %[[VAL_62]] = br %[[VAL_93]] : index
// CHECK:           %[[VAL_64]] = br %[[VAL_94]] : index
// CHECK:           %[[VAL_66]] = br %[[VAL_95]] : index
// CHECK:           %[[VAL_69]] = br %[[VAL_96]] : none
// CHECK:           %[[VAL_71]] = br %[[VAL_98]] : index
// CHECK:           %[[VAL_99:.*]] = merge %[[VAL_80]] : index
// CHECK:           %[[VAL_100:.*]] = merge %[[VAL_82]] : index
// CHECK:           %[[VAL_101:.*]]:2 = fork [2] %[[VAL_100]] : index
// CHECK:           %[[VAL_102:.*]] = merge %[[VAL_84]] : index
// CHECK:           %[[VAL_103:.*]], %[[VAL_104:.*]] = control_merge %[[VAL_86]] : none
// CHECK:           sink %[[VAL_104]] : index
// CHECK:           %[[VAL_105:.*]] = arith.addi %[[VAL_99]], %[[VAL_101]]#1 : index
// CHECK:           %[[VAL_24]] = br %[[VAL_101]]#0 : index
// CHECK:           %[[VAL_20]] = br %[[VAL_102]] : index
// CHECK:           %[[VAL_17]] = br %[[VAL_103]] : none
// CHECK:           %[[VAL_27]] = br %[[VAL_105]] : index
// CHECK:           %[[VAL_106:.*]], %[[VAL_107:.*]] = control_merge %[[VAL_36]] : none
// CHECK:           sink %[[VAL_107]] : index
// CHECK:           return %[[VAL_106]] : none
// CHECK:         }
func @affine_apply_loops_shorthand(%arg0: index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  cf.br ^bb1(%c0 : index)
^bb1(%0: index):      // 2 preds: ^bb0, ^bb5
  %1 = arith.cmpi slt, %0, %arg0 : index
  cf.cond_br %1, ^bb2, ^bb6
^bb2: // pred: ^bb1
  %c42 = arith.constant 42 : index
  %c1_0 = arith.constant 1 : index
  cf.br ^bb3(%0 : index)
^bb3(%2: index):      // 2 preds: ^bb2, ^bb4
  %3 = arith.cmpi slt, %2, %c42 : index
  cf.cond_br %3, ^bb4, ^bb5
^bb4: // pred: ^bb3
  %4 = arith.addi %2, %c1_0 : index
  cf.br ^bb3(%4 : index)
^bb5: // pred: ^bb3
  %5 = arith.addi %0, %c1 : index
  cf.br ^bb1(%5 : index)
^bb6: // pred: ^bb1
  return
}
