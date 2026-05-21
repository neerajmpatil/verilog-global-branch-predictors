        .data
c:      .word   0

        .text
        .globl  main

main:
        la      $s0, c
        addi    $t0, $zero, 0

outer_loop:
        addi    $t1, $zero, 0

inner_loop:
        lw      $t4, 0($s0)
        addi    $t4, $t4, 1
        sw      $t4, 0($s0)
        addi    $t1, $t1, 1
        slti    $t3, $t1, 5
        bne     $t3, $zero, inner_loop

        addi    $t0, $t0, 1
        slti    $t2, $t0, 1000
        bne     $t2, $zero, outer_loop

end:
        lw      $v0, 0($s0)
        jr      $ra
