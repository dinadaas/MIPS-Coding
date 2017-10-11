.data
    buffer: .space 64
    str: .asciiz "DONE"
    newline: .asciiz "\n"
    Pname: .asciiz "Pizza name:"
    Pdiameter: .asciiz "Pizza diameter:"
    Pcost: .asciiz "Pizza cost:"
    PI: .float 3.14159265358979323846
    space:      .asciiz " "

.text

    main:
        addi $sp, $sp, -12
        sw  $ra, 0($sp)
        sw  $s0, 4($sp)
        sw  $s1, 8($sp)

        li      $v0, 9          #Allocates memory for pizza
        li      $a0, 80         #(lname 64/diam 4/cost 4/cpi 4/next 4)
        syscall                 #stores head in $s1
        move    $s1, $v0        #and sets head to current
        move    $s0, $s1        #

        li      $v0, 4          #Asks for pizza name
        la      $a0, Pname       #
        syscall                 #
        li      $v0, 8          #
        la      $a0, buffer   #
        li      $a1, 64         #
        syscall                 #

        li      $t0, 0          #$t0 stores i

    namestore:
        la      $t1, buffer   #$t1 stores current index
        move    $t2, $s1        #$t2 stores current index within pizza
        add     $t1, $t1, $t0
        add     $t2, $t2, $t0
        lb      $t3, 0($t1)
        sb      $t3, 0($t2)
        beqz    $t3, diameterstore #0 is null char right?
        addi    $t0, 1          #i++
        j       namestore

    diameterstore:
        addi    $t2, -1         #Gets rid of the
        sb      $0, 0($t2)      #new line

        li      $v0, 4          #Asks for diam
        la      $a0, Pdiameter       #and stores in $f1
        syscall                 #
        li      $v0, 6          #
        syscall                 #
        mov.s   $f1, $f0        #
        s.s     $f1, 64($s0)    #

    coststore:
        li      $v0, 4          #Asks for cost
        la      $a0, Pcost       #and stores in $f2
        syscall                 #
        li      $v0, 6          #
        syscall                 #
        mov.s   $f2, $f0        #
        s.s     $f2, 68($s0)    #

    pizzaperdollar:   #(PI*diam*diam/4)/cst;
        li.s    $f7, 0.0
        c.eq.s  $f2, $f7
        bc1t    ppdauto
        li.s    $f7, 0.0
        c.eq.s  $f1, $f7
        bc1t    ppdauto
        mul.s   $f4, $f1, $f1
        l.s     $f5, PI
        mul.s   $f4, $f5, $f4
        li.s    $f6, 4.0
        div.s   $f4, $f4, $f6
        div.s   $f3, $f4, $f2   #Computes inches per dollar
        s.s     $f3, 72($s0)    #and stores in $f3
        j readpizza
    ppdauto:
        li.s    $f3, 0.0

    readpizza:
        li      $v0, 4          #Asks for piz
        la      $a0, Pname       #
        syscall                 #
        li      $v0, 8          #
        la      $a0, buffer   #
        li      $a1, 64         #
        syscall                 #

        li      $t4, 0          #i
    seeifdone:
        la      $t0, str 
        la      $t1, buffer
        add     $t0, $t0, $t4
        add     $t1, $t1, $t4  
        lb      $t2, 0($t0)
        lb      $t3, 0($t1)
        addi    $t4, 1
        beqz    $t2, checkdone
        beq     $t2, $t3, seeifdone#If equal, compare next char

    checkdone:
        li      $t5, 5          #Checks if 4 char have been compared
        beq     $t5, $t4, sort  #   !!There's a case when name is DONEsometihng!!

        li      $v0, 9          #Allocates memory for another pizza
        li      $a0, 80         #
        syscall                 #
        la      $t0, 0($v0)     #Sets the previous node to point to the new one
        sw      $t0, 76($s0)    #
        move    $s0, $v0        #Updates current node

        li      $t0, 0          #$t0 stores i

    namestore2:
        la      $t1, buffer   #$t1 stores current index of pizza
        move    $t2, $s0        #$t2 stores current index of pizza
        add     $t1, $t1, $t0
        add     $t2, $t2, $t0
        lb      $t3, 0($t1)
        sb      $t3, 0($t2)
        beqz    $t3, diameterstore2#0 is null char right?
        addi    $t0, 1          #i++
        j       namestore2
        
    diameterstore2:
        addi    $t2, -1         #Gets rid of newline
        sb      $0, 0($t2)      #
        li      $v0, 4          #Asks for diameter
        la      $a0, Pdiameter       #and stores in $f1
        syscall                 #
        li      $v0, 6          #
        syscall                 #
        mov.s   $f1, $f0        #
        s.s     $f1, 64($s0)    #

    coststore2:
        li      $v0, 4          #Asks for cost
        la      $a0, Pcost       #and stores in $f2
        syscall                 #
        li      $v0, 6          #
        syscall                 #
        mov.s   $f2, $f0        #
        s.s     $f2, 68($s0)    #
        j pizzaperdollar

    sort: 
        move    $a0, $s1
        subu    $sp, 24
        sw      $t5, 20($sp)
        sw      $t4, 16($sp)
        sw      $t3, 12($sp)
        sw      $t2, 8($sp)
        sw      $t1, 4($sp)
        sw      $t0, 0($sp) 
        jal     mergesort
        lw      $t0, 0($sp)
        lw      $t1, 4($sp)
        lw      $t2, 8($sp)
        lw      $t3, 12($sp)
        lw      $t4, 16($sp)
        lw      $t5, 20($sp)
        addu    $sp, 24 

    move        $s1, $v0        #Changes head to head of sorted list

    print:
        beqz    $s1, clean
        li      $v0, 4
        move    $a0, $s1
        syscall
        li      $v0, 4
        la      $a0, space
        syscall
        li      $v0, 2
        l.s     $f12, 72($s1)
        syscall
        li      $v0, 4
        la      $a0, newline
        syscall
        lw      $s1, 76($s1)
        j       print

    clean:
        move    $v0, $0
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $ra, 8($sp)
        addu    $sp, 12

        li $v0, 10
        syscall

        jr      $ra
    .end main

    mergesort:
        addi    $sp, $sp, -36
        sw      $ra, 32($sp)
        s.s     $f0  28($sp)
        s.s     $f1, 24($sp)
        sw      $s5, 20($sp)    #Linked list in middle
        sw      $s4, 16($sp)    #Stores 2 for division
        sw      $s3, 12($sp)    #Stores address of next node
        sw      $s2, 8($sp)     #Current node
        sw      $s1, 4($sp)     #All purpose counter
        sw      $s0, 0($sp)     #Head of linked list

        move    $s0, $a0        #Set head of linked list
    basecase1:
        beqz    $s0, nullnode
        li      $s1, 1
        move    $s2, $s0        #Set current node to head

    loop1:
        lw      $s3, 76($s2)
        beqz    $s3, countdone
        addi    $s1, 1
        move    $s2, $s3
        j       loop1

    countdone:
    basecase2:
        addi    $s1, -1         #Second base case
        beqz    $s1, onenode    #Only one node
        addi    $s1, 1

        li      $s4, 2
        div     $s1, $s4
        mflo    $s1             #Updates counter to half the list length
        addi    $s1, -1         #In order to delink list at halfway point

        move    $s2, $s0        #Sets current node back to head

    halfloop:
        lw      $s3, 76($s2)
        beqz    $s1, donehalf
        addi    $s1, -1
        move    $s2, $s3
        j       halfloop

    donehalf:
        move    $s5, $s2
        lw      $s2, 76($s2)
        sw      $0, 76($s5)     #Delinks

        move    $a0, $s0
        ##Saving t's
        subu,   $sp, 16
        sw      $t3, 12($sp)
        sw      $t2, 8($sp)
        sw      $t1, 4($sp)
        sw      $t0, 0($sp)
        #########
        jal     mergesort
        ##Restoring t's
        lw      $t0, 0($sp)
        lw      $t1, 4($sp)
        lw      $t2, 8($sp)
        lw      $t3, 12($sp)
        addu    $sp, 16
        #########
        move    $t0, $v0
        move    $a0, $s2
        ##Saving t's
        subu,   $sp, 16
        sw      $t3, 12($sp)
        sw      $t2, 8($sp)
        sw      $t1, 4($sp)
        sw      $t0, 0($sp)
        ##########
        jal     mergesort
        ##Restoring t's
        lw      $t0, 0($sp)
        lw      $t1, 4($sp)
        lw      $t2, 8($sp)
        lw      $t3, 12($sp)
        addu    $sp, 16
        ##########
        move    $t1, $v0

        l.s     $f0, 72($t0)    #Load cpi
        l.s     $f1, 72($t1)    #Load cpi
        c.lt.s  $f0, $f1
        bc1t    head2
        j       head1

    head1:                      
        move    $s0, $t0        
        lw      $t0, 76($t0)    
        j       newlist         

    head2:
        move    $s0, $t1
        lw      $t1, 76($t1)

    newlist:
        move    $t3, $s0        #$t3 stores current node in new list

    merge:
        sub     $t2, $t0, $t1
        beqz    $t2, notbasecase
        beqz    $t0, merge2
        beqz    $t1, merge1
        l.s     $f0, 72($t0)    #Load cpi
        l.s     $f1, 72($t1)    #Load cpi
        c.lt.s  $f0, $f1
        bc1t    merge2
        j       merge1

    merge1:
        sw      $t0, 76($t3)
        lw      $t3, 76($t3)
        beqz    $t0, merge
        lw      $t0, 76($t0)
        j       merge

    merge2:
        sw      $t1, 76($t3)
        lw      $t3, 76($t3)
        beqz    $t1, merge
        lw      $t1, 76($t1)
        j       merge

    nullnode:
        move    $v0, $0
        j       clean2

    onenode:
        move    $v0, $s0
        j       clean2

    notbasecase:
        move    $v0, $s0        #Returns head of mergedlist

    clean2:
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        l.s     $f0, 24($sp)
        l.s     $f1, 28($sp)
        lw      $ra, 32($sp)
        addi    $sp, 36
        jr      $ra 

    .end mergesort