\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])
	m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])

	m4_test_prog()
\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   
   // YOUR CODE HERE
   // Muhammad Naqi Raza
   `BOGUS_USE($imm_valid)
   // PC logic
   $next_pc[31:0] = $reset ? 0 : 
                    $taken_br ? $br_tgt_pc : 
                    $is_jal ? $br_tgt_pc :
                    $is_jalr ? $jalr_tgt_pc : 
                    (>>1$next_pc[31:0] + 4);
   $pc[31:0] = >>1$next_pc;
   
   
   
   // 	Instruction Memory
   `READONLY_MEM($pc, $$instr[31:0]);
   
   
   // Decode Logic
   // Upper immediate Instruction
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   
   // Immediate Instruction
   $is_i_instr = $instr[6:2] == 5'b00000 || 
                 $instr[6:2] == 5'b00001 || 
                 $instr[6:2] == 5'b00100 || 
                 $instr[6:2] == 5'b00110 || 
                 $instr[6:2] == 5'b11001;
   
   // R type Instruction
   $is_r_instr = $instr[6:2] == 5'b01011 || 
                 $instr[6:2] == 5'b01100 || 
                 $instr[6:2] == 5'b01110 || 
                 $instr[6:2] == 5'b10100;
   
   // Store instruction
   
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   
   // Branch Instruction
   $is_b_instr = $instr[6:2] == 5'b11000;
   
   //Jump Instruction
   $is_j_instr = $instr[6:2] == 5'b11011;
   
   
   // Instruction fields
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0] = $instr[19:15];
   $rs2[4:0] = $instr[24:20];
   $rd[4:0] = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
   
   $rs2_valid = $is_r_instr || 
                $is_s_instr || 
                $is_b_instr;
   
   $imm_valid = ~ ($is_r_instr);
   
   $rd_valid = ~ ($is_b_instr || $is_s_instr);
   
   $rs1_valid = ~ ($is_j_instr || $is_u_instr);
   /* verilator lint_off WIDTHEXPAND */
   /* verilator lint_off WIDTHTRUNC */
   $imm[31:0] = $is_i_instr ? {{21{$instr[31]}}, $instr[30:20]} :
             $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:8], $instr[7]} :
             $is_b_instr ? {{11{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
             $is_u_instr ? {$instr[31:12], 20'b0} :
             $is_j_instr ? {{11{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 3'b0} :
             32'b0;
   
   /* verilator lint_on WIDTHEXPAND */
   /* verilator lint_on WIDTHTRUNC */
   
   // Decode Logic
   $dec_bits[10:0] = {$instr[30], $funct3, $opcode};
   
   $is_beq = $dec_bits ==? 11'bx0001100011;
   $is_bne = $dec_bits ==? 11'bx0011100011;
   $is_blt = $dec_bits ==? 11'bx1001100011;
   $is_bge = $dec_bits ==? 11'bx1011100011;
   $is_bltu = $dec_bits ==? 11'bx1101100011;
   $is_bgeu = $dec_bits ==? 11'bx1111100011;
   $is_addi = $dec_bits ==? 11'bx0000010011;
   $is_add = $dec_bits ==? 11'b00000110011;
   
   
   
   $is_lui = $dec_bits ==? 11'bxxxx0110111;
   $is_auipc = $dec_bits ==? 11'bxxxx0010111;
   $is_jal = $dec_bits ==? 11'bxxxx1101111;
   $is_jalr = $dec_bits ==? 11'bx0001100111;
   
   $is_slti = $dec_bits ==? 11'bx0100010011;
   $is_sltiu = $dec_bits ==? 11'bx0110010011;
   
   $is_xori = $dec_bits ==? 11'bx1000010011;
   $is_ori = $dec_bits ==? 11'bx1100010011;
   $is_andi = $dec_bits ==? 11'bx1110010011;
   
   $is_slli = $dec_bits ==? 11'b00010010011;
   $is_srli = $dec_bits ==? 11'b01010010011;
   $is_srai = $dec_bits ==? 11'b11010010011;
   
   $is_sub = $dec_bits ==? 11'b10000110011;
   $is_sll = $dec_bits ==? 11'b00010110011;
   $is_slt = $dec_bits ==? 11'b00100110011;
   $is_sltu = $dec_bits ==? 11'b00110110011;
   $is_xor = $dec_bits ==? 11'b01000110011;
   $is_srl = $dec_bits ==? 11'b01010110011;
   $is_sra = $dec_bits ==? 11'b11010110011;
   $is_or = $dec_bits ==? 11'b01100110011;
   $is_and = $dec_bits ==? 11'b01110110011;
   
   $write_value[31:0] = $is_s_instr ? $ld_data : $result;
   
   
   
   
   
   // Load instruction
   $is_load = $opcode ==? 7'b0000011;
   
   
   // Register File Macro at the 2nd last line of the code
   
   // ALU
   
   // SLTU and SLTI Result
   $sltu_rslt[31:0] = {31'b0, $src1_value < $src2_value};
   $sltiu_rslt[31:0] = {31'b0, $src1_value <$imm};
   
   //SRA and Result
   $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value };
   $sra_rslt[63:0] = $sext_src1 >> $src2_value[4:0];
   $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
   /* verilator lint_off WIDTHTRUNC */
   /* verilator lint_off WIDTHEXPAND */
   $result[31:0] = ($is_load | $is_s_instr | 
                   $is_addi ) ? $src1_value + $imm :
                   $is_add ? $src1_value + $src2_value : 
                   $is_andi ? $src1_value & $imm : 
                   $is_ori ? $src1_value | $imm :
                   $is_xori ? $src1_value ^ $imm : 
                   $is_slli ? $src1_value << $imm[5:0] :
                   $is_srli ? $src1_value >> $imm[5:0] :
                   $is_and ? $src1_value & $src2_value :
                   $is_or ? $src1_value | $src2_value :
                   $is_xor ? $src1_value ^ $src2_value :
                   $is_sub ? $src1_value - $src2_value :
                   $is_sll ? $src1_value << $src2_value :
                   $is_srl ? $src1_value >> $src2_value :
                   $is_sltu ? $sltu_rslt : 
                   $is_sltiu ? $sltiu_rslt : 
                   $is_lui ? {$imm[31:12], 12'b0} :
                   $is_auipc ? $pc + $imm : 
                   $is_jal ? $pc + 4 : 
                   $is_jalr ? $pc + 4 : 
                   $is_slt ? ( ($src1_value[31] == $src2_value[31]) ? 
                              $sltu_rslt :
                              {31'b0, $src1_value[31]} ) : 
                   $is_slti ? ( ($src1_value[31] == $imm[31]) ? 
                              $sltiu_rslt :
                              {31'b0, $src1_value[31]} ) : 
                   $is_sra ? $sra_rslt : 
                   $is_srai ? $srai_rslt :
                   32'b0;
   /* verilator lint_on WIDTHEXPAND */
   /* verilator lint_off WIDTHTRUNC */
   
   // Branch Logic
   $taken_br = $is_beq ? ($src1_value == $src2_value) : 
               $is_bne ? ($src1_value != $src2_value) :
               $is_blt ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) : 
               $is_bge ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) : 
               $is_bltu ? ($src1_value < $src2_value) : 
               $is_bgeu ? ($src1_value >= $src2_value) :
               0;
   
   $br_tgt_pc[31:0] = $pc + $imm;
   $jalr_tgt_pc[31:0] = $src1_value + $imm;
   
   
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+rf(32, 32, $reset, ($rd_valid && $rd != 0), $rd, $write_value, $rs1_valid, $rs1, $src1_value, $rs2_valid, $rs2, $src2_value)
   m4+dmem(32, 32, $reset, $result, $is_s_instr, $src2_value, $is_load, $ld_data)
   m4+cpu_viz()
\SV
   endmodule