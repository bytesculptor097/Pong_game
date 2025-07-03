set p1 0
set p2 0
#Making the window and replay button
set c [canvas .mycan -background grey  -width 600 -height 400]
pack .mycan
button .mybutton -text "Reset" -command {
    set p1 0
    set p2 0
    .mycan itemconfigure $score_text -state normal
    .mycan itemconfigure $winner_text -state hidden
    .mycan itemconfigure $ball -state normal
    .mycan itemconfigure $score_text -text "0 : 0"
}

pack .mybutton

#Setting the initial variables
set rec [.mycan create rectangle  20 160 30 240 -fill blue -outline black -width 6]
set rec2 [.mycan create rectangle  570 160 580 240 -fill red -outline black -width 6]
set ball [.mycan create oval 292 372 308 388 -fill white -outline black -width 6]
set dx -15
set dy -5
set gameover ""
set gameloop ""
set movingUp1 0
set movingDown1 0
set movingUp2 0
set movingDown2 0
set score_text [.mycan create text 300 20 -text "0 : 0" -fill black -font "Helvetica 16 bold"]



#Binding keys to interact the game with the keys
bind . <KeyPress-w> { set movingUp1 1 }
bind . <KeyRelease-w> { set movingUp1 0 }
bind . <KeyPress-s> { set movingDown1 1 }
bind . <KeyRelease-s> { set movingDown1 0 }
bind . <KeyPress-Up> { set movingUp2 1 }
bind . <KeyRelease-Up> { set movingUp2 0 }
bind . <KeyPress-Down> { set movingDown2 1 }
bind . <KeyRelease-Down> { set movingDown2 0 }

#Soothing the paddles
proc update_paddles {} {
    global c rec rec2 movingUp1 movingDown1 movingUp2 movingDown2 

    if {$movingUp1} {
        $c move $rec 0 -10
    }
    if {$movingDown1} {
        $c move $rec 0 10
    }
    if {$movingUp2} {
        $c move $rec2 0 -10
    }
    if {$movingDown2} {
        $c move $rec2 0 10
    }



    after 20 update_paddles
}
update_paddles

#Restarting the game 
proc restart_game {} {
    global c ball dx dy gameloop rec rec2 p1 p2 score_text 

    # Cancel previous loop
    if {$gameloop ne ""} {
        after cancel $gameloop
        set gameloop ""
    }

    # Reset ball and paddles
    $c coords $ball 292 372 308 388
    $c coords $rec 20 160 30 240
    $c coords $rec2 570 160 580 240

    # Reset speed
    set dx -6
    set dy -5

    # Start loop again
    set gameloop [after 20 throw_ball_in_starting]
}


proc score {} {
        global ball score_text rec rec2 c dx dy p1 p2 gameloop winner_text
        if {[catch {$c coords $ball} coords]} {
        return
        }
        if {[llength $coords] != 4} {
        return
        }
	
        set coords [$c coords $ball]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [lindex $coords 2]
        set y2 [lindex $coords 3]
        set overlap [$c find overlapping $x1 $y1 $x2 $y2]

        if {$x1 <= 0} {
                incr p2
                $c itemconfigure $score_text -text "$p1 : $p2"

            	if {$p2 == 10} {
                set winner_text [$c create text 300 200 -text "Player 2 Wins!" -fill red -font "Helvetica 20 bold"]
                after cancel $gameloop
                return
                }
		restart_game
        }
        if {$x2 >= 600} {
		incr p1
		$c itemconfigure $score_text -text "$p1 : $p2"
		if {$p1 == 10} {
                set winner_text [$c create text 300 200 -text "Player 1 Wins!" -fill blue -font "Helvetica 20 bold"]
                after cancel $gameloop
                return
        }


                restart_game
       }



}

#Main instruction of the game 
proc game_instr {} {
        global ball rec dx dy c rec2 gameover
        if {[catch {$c coords $ball} coords]} {
        return
        }
        if {[llength $coords] != 4} {
        return
        }
        set coords [$c coords $ball]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [lindex $coords 2]
        set y2 [lindex $coords 3]
        set overlap [$c find overlapping $x1 $y1 $x2 $y2]

        if {[lsearch -exact $overlap $rec] != -1} {
                set dx [expr -$dx]
		.mycan itemconfigure $ball -fill red
                after 200 {.mycan itemconfigure $ball -fill white}
        }

	if {[lsearch -exact $overlap $rec2] != -1} {
                set dx [expr -$dx]
		.mycan itemconfigure $ball -fill red
                after 200 {.mycan itemconfigure $ball -fill white}
       }

       if {$y1 <= 0 || $y2 >= 400} {
        set dy [expr -$dy]
       }

       
}

#Proc for throwing the ball in starting
proc throw_ball_in_starting {} {
        global ball gameloop dx dy p1 p2 rec rec2 c score_text
        .mycan move $ball $dx $dy
        if {$p1 == 10 || $p2 == 10} {
              .mycan itemconfigure $ball -state hidden
              .mycan itemconfigure $score_text -state hidden

        }
        game_instr
	score
        set gameloop [after 20 throw_ball_in_starting]
}

after 2000 {throw_ball_in_starting}

