; color (0=black, 1=red, -1=free)
; value
; p_left (-1 == nil)
; p_right (-1 == nil)
; p_parent

; memory map:
; 0: number_of_mallocated_entries
; 1: root
; 1000 + 5*n particular allocated thing



call 1 ; _init
call 1000 ; main
exit

label 190 ; (addr) safe_getval (addr) (val)
	dup
label 191 ; (addr) unsafe_getval (val)
	push 1
	add
	load
	ret

label 192 ; (addr) getright (addr/-1)
	push 1
	add
label 193 ; (addr) getleft (addr/-1)
	push 2
	add
	load
	ret

label 200 ; (addr_number) (addr_root) append_number (-)
	call 190 ; safe_getval
	copy 2
	call 191 ; unsafe_getval
	sub
	;stack: (addr_number) (addr_root) val_root-val_number
	jn 202 ; number_bigger_than_root
	; number_lower_than_root
	dup
	call 193 ; getleft
	dup

	jn 210 ; append_left
	; recurse to the left
	slide 1
	jump 200

	label 210 ; append_left
	pop
	; set_left

	copy 1
	copy 1

	push 2
	add
	swap
	store

	swap
	push 4
	add
	swap
	store

	ret

	label 202
	; number_bigger_than_root

	dup
	call 192 ; getright
	dup

	jn 212
	slide 1
	jump 200

	label 212
	pop
	; set right
	copy 1
	copy 1

	push 3
	add
	swap
	store

	swap
	push 4
	add
	swap
	store

	ret

label 215 ; (addr_node) getuncle (addr_uncle)
	push 4
	add
	load ; (parent)

	dup
	push 4
	add
	load
	; (parent) (grandparent)
	swap
	copy 1
	; (grandparent) (parent) (grandparent)
	push 3
	add
	load
	; (gp) (parent) (gp->right)
	sub
	; (gp) (parent ==? gp->right)
	jz 216 ; uncle is left
	; uncle is right
	push 1
	add
	label 216 ; uncle is left
	push 2
	add
	load
	ret

label 217 ; (addr_node) getchildcase (0-3)

	push 0
	swap

	dup
	push 4
	add
	load

	swap
	copy 1
	; 0 (parent) (node) (parent)
	push 2
	add
	load
	; 0 (parent) (node) (parent->left)
	sub
	jz 218
	slide 1
	push 1
	swap	
	label 218


	dup
	push 4
	add
	load
	; 0/1 parent gp
	push 2
	add
	load
	; 0/1 parent gp->left
	sub
	jz 219

	push 2
	add

	label 219

	ret


label 220 ; (addr_number) repaint (-)

;	push 42
;	ochr
;	dup
;	call 10 ; puti
;	push 42
;	ochr




	dup

	push 4
	add
	load

	; (n) (p)

	; if I am root, then black and done

	jn 221 ; it IS root
	jump 222

	label 221
	push 0
	store
	ret ; nothing more to do for root

	label 222
	; if my parent is root, then red and done

	dup
	push 4
	add
	load

	push 4
	add
	load
	; (n) (g)

	jn 223 ; has_parent_root
	jump 224
	label 223

	pop
	ret

	label 224 ; "could have uncle"

	; (n)

	;; if uncle is red...
	dup ; backup the node address in case uncle is black
	call 215 ; getuncle
	dup

	load
	dup
	; (n) (uncle) (color) (color)
	jn 230
	; (n) (uncle) (color)
	dup
	jz 230 ; uncle_is_black
	; (n) (uncle) (color)
	pop

	; uncle_is_red ; stack: (node) (uncle)

	push 0 ; change color of uncle to black
	store

	push 4 ; change color of parent to black
	add
	load
	dup
	push 0
	store

	push 4 ; grand parent to red
	add
	load
	dup
	push 1
	store
	; stack: (grandparent)
	jump 220 ; repeat steps 2, 3 for grandparent


	label 230
	; (n) (uncle) (color)
	pop

	; TODO uncle_is_black ; stack: (node) (uncle)
	pop

	dup
	call 217 ; getchildcase

	push 38
	ochr
	dup
	call 10 ; puti
	push 38
	ochr

	dup
	jz 240
	push 1
	sub
	dup
	jz 250
	push 1
	sub
	jz 260
	; rr
	; stack: (node)
	pop
	ret

	label 240 ; ll
	; stack: (node) (result)
	pop


	push 4
	add
	load

	dup

	push 4
	add
	load

	; stack: (p) (g)

	; p->parent = g->parent
	copy 1
	push 4
	add	; (p) (g) (p[parent])

	copy 1
	push 4
	add
	load	; (p) (g) (p[parent]) (g->parent)

	store ; (p) (g)

	dup
	push 4
	add
	load	; (p) (g) (gg)

	dup
	jn 241
		; (p) (g) (gg)
		; g->parent->left_or_right = p
		break
		dup
		push 2
		add
		load ; (p) (g) (gg) (gg->left)
		copy 2
		sub ; (p) (g) (gg) (result)
		jz 243
		push 1
		add
		label 243
		push 2
		add
		; (p) (g) (gg[correct])
		copy 2
		store ; (p) (g)
	jump 242
	label 241
		; (p) (g) -1
		pop
		; root = p
		copy 1
		push 1
		swap
		store

	label 242
	
	; g->parent = p
	dup
	push 4
	add ; (p) (g) (g[parent])
	copy 2
	store

	; g->left = p->right
	; (p) (g)
	dup
	push 2
	add
	copy 2
	push 3
	add
	load
	store

	; p->right = g
	; (p) (g)
	copy 1
	push 3
	add
	copy 1
	store

	; coloring

	push 1
	store
	push 0
	store
	ret

	label 250 ; lr
	; stack: (node) (result)
	pop



	dup
	push 4
	add
	load

	; (x) (p)

	; x->parent = p->parent
	copy 1
	push 4
	add
	copy 1
	push 4
	add
	load
	store

	; g->left = p
	dup
	push 4
	add
	load
	push 2
	add
	copy 1
	store

	; p->right = x->left
	dup
	push 3
	add
	copy 2
	push 2
	add
	load
	store

	; x->left = p
	; (x) (p)
	dup
	copy 2
	push 2
	add
	swap
	store

	; (x) (p)
	swap
	copy 1

	; p->parent = x
	push 4
	add
	swap
	store

	push 1
	jump 240

	label 260 ; rl
	; stack: (node)

	pop
	ret

label 300 ; delete_number
	ret

label 400 ; display_tree
	ret

label 450 ; (-) dump_mem (-)
	push -1
	push 32  ; 
	push 58  ; :
	push 107 ; k
	push 111 ; o
	push 108 ; l
	push 65  ; A
	call 2 ; puts

	push 0
	load
	dup

	call 10 ; puti

	push -1
	push 32  ; 
	push 58  ; :
	push 116 ; t
	push 111 ; o
	push 111 ; o
	push 82  ; R
	push 32
	call 2 ; puts

	push 1
	load
	call 10 ; puti

	push 10 ; \n
	ochr



	push 1000

	label 451
	; how_many_entries current_address

	swap
	dup
	jz 452
	push 1
	sub
	swap
	; body
	
	dup

	push 40 ; (
	ochr
	push 64 ; @
	ochr
	dup
	call 10 ; puti
	push 32 ;
	ochr


	load ; color

	dup
	jn 453 ; color==hole
	jz 454 ; color==black

	 ; color==red
	push -1
	push 32 ; 

	push 109
	push 48
	push 91
	push 27

	push 100 ; d
	push 101 ; e
	push 114 ; r

	push 109
	push 49
	push 51
	push 91
	push 27

	call 2  ; puts
	jump 455

	label 453 ; color==hole

	pop

	push -1
	push 101 ; e
	push 108 ; l
	push 111 ; o
	push 104 ; h
	call 2  ; puts
	jump 456

	label 454 ; color==black
	push -1
	push 32 ;

	push 109
	push 48
	push 91
	push 27

	push 107 ; k
	push 99 ; c
	push 97 ; a
	push 108 ; l
	push 98 ; b

	push 109
	push 49
	push 91
	push 27

	call 2  ; puts

	label 455

	push 1
	add
	dup
	load
	call 10 ; puti

	push 32 ;
	ochr
	push 76 ; L
	ochr

	push 1
	add
	dup
	load
	call 10 ; puti

	push 32 ;
	ochr
	push 82 ; R
	ochr

	push 1
	add
	dup
	load
	call 10 ; puti

	push 32 ;
	ochr
	push 80 ; P
	ochr

	push 1
	add
	dup
	load
	call 10 ; puti

	push 4
	sub

	label 456 ; end of body

	push 41 ; )
	ochr

	push 5
	add
	jump 451

	label 452
	push 10
	ochr

	pop
	pop
	ret


label 500 ; (val) (color) malloc (addr)
	; break
	push 0
	load

	dup
	push 1
	add
	push 0
	swap
	store


	push 5
	mul
	push 1000
	add

; val color addr
	swap
	copy 1
	swap

	store

; val addr

	swap
	copy 1
	push 1
	add
	swap

	store
; addr
	dup
	push 2
	add

	dup
	push 1
	add
	dup
	push 1
	add
	push -1
	store
	push -1
	store
	push -1
	store

	ret

label 600 ; (addr) free (-)
	; push 5
	; mul
	; push 1000
	; add
	push -1
	store
	ret

label 1 ; _init
	push 0
	push 0
	store
	ret

label 2 ; (-1) (tnirp to gnirts) puts (-) ; prints inverted string

	dup
	jn 3
	ochr
	jump 2
	label 3
	pop
	ret

label 10 ; (N) puti (-) ; prints number

	push -1
	swap

	label 12

	dup
	push 10
	mod
	push 48
	add

	swap
	dup
	jz 11

	push 10
	div
	jump 12

	label 11

	pop ; remove terminating zero

	copy 1 ; -1 if this is a first zero
	jn 2 ; puts
	pop
	jump 2 ; puts


label 1000 ; main

;;;;; ROOT
	push 230
	 push 0
	call 500 ; malloc
	push 1
	swap
	store ; remember the root address

	call 450 ; dump_mem

;;;;; NUMBERS

	push -1
	push 11
	push 56
	push 4
	push 17
	push 290
	push 220

;;;;; ADDING LOOP

	label 1010
	dup
	jn 1012

	push 1 ; red
	call 500 ; malloc

	dup
	push 1
	load ; root
	call 200 ; append_number

	call 220 ; repaint
	call 450 ; dump_mem

	jump 1010

	label 1012

	ret

