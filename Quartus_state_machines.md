State machine implementation on Quartus
=======================================

There are several techniques for writing state machines in Verilog or SystemVerilog.  
During this project I took the time to explore different methods and their implementation result on Quartus (Quartus Lite 21.1.1 Build 850 on MAX10 devices to be exact).
I came up with interesting results.
The exact code I have tested can be found in all 4 branches whose name starts with `state_machine` .  
The exact results are in a spreadsheet named `lcd_ctrl_state_machine.xlsx`

State machine types:
--------------------
I've checked a few implementation styles with a few variations on them:  

1. Plain state machine, with states implemented as full one hot values as enums, and regular case statement on the state variable.  
```
typedef enum int unsigned { 
	INIT = 1 << 0, 
	NEXT = 1 << 1,
	DONE = 1 << 2
} states_t;
logic [states_t.num()-1:0]state, state_next;

logic out;
logic out_next;

always_comb begin
    out = 0;
    case(state)
        INIT:
            if (in1)
                state_next = NEXT;
            else if (rst)
                state_next = INIT;
        NEXT:
            if (in2)
                state_next = DONE;
            else if (rst)
                state_next = INIT;
            else
                state_next = NEXT;
        DONE:
            out = 1;
            state_next = INIT;
    endcase
end

always_ff @(posedge clk) begin
    out <= out_next;
    state <= next_state;
end
```

2. Plain state machine, with states implemented as full one hot values, but enums are encoding bit positions, and all references are via `1 << STATE_ENUM` .  
The coding style is a bit more cumbersome, but the advantage is that the states are auto-numbered by the enum section.
```
typedef enum int unsigned { 
	INIT, 
	NEXT,
	DONE
} states_t;
logic [states_t.num()-1:0]state, state_next;

logic out;
logic out_next;

always_comb begin
    out = 0;
    case(state)
        1<<INIT:
            if (in1)
                state_next = 1<<NEXT;
            else if (rst)
                state_next = 1<<INIT;
        1<<NEXT:
            if (in2)
                state_next = 1<<DONE;
            else if (rst)
                state_next = 1<<INIT;
            else
                state_next = 1<<NEXT;
        1<<DONE:
            out = 1;
            state_next = 1<<INIT;
    endcase
end

always_ff @(posedge clk) begin
    out <= out_next;
    state <= next_state;
end
```

3. Plain state machine, with states implemented as binary values, with enums encoding state values.  
This coding style is very similar to (1) except we use normal binary values by letting the enum assign the states in order.
In addition, the state variable size is smaller.
```
typedef enum int unsigned { 
	INIT, 
	NEXT,
	DONE
} states_t;
logic [$clog2(states_t.num())-1:0]state, state_next;

logic out;
logic out_next;

always_comb begin
    out = 0;
    case(state)
        INIT:
            if (in1)
                state_next = NEXT;
            else if (rst)
                state_next = INIT;
        NEXT:
            if (in2)
                state_next = DONE;
            else if (rst)
                state_next = INIT;
            else
                state_next = NEXT;
        DONE:
            out = 1;
            state_next = INIT;
    endcase
end

always_ff @(posedge clk) begin
    out <= out_next;
    state <= next_state;
end
```

4. Reverse case state machine, with states implemented as full one hot values, but enums are encoding bit positions, and states are set and checked via `state[STATE_ENUM]`  
This is the classical ASIC writing style. In the *reverse case* state machine, a fixed `case(1'b1)` statement is used, and the case items are registers, not numerical constants.  
The advantage of this writing style is that while we write all one-hot state bits when changing state, we only check a single state bit.  
```
typedef enum int unsigned { 
	INIT, 
	NEXT,
	DONE
} states_t;
logic [$clog2(states_t.num())-1:0]state, state_next;

logic out;
logic out_next;

always_comb begin
    out = 0;
    state_next = '0;
    case(1'b1)
        state[INIT]:
            if (in1)
                state_next[NEXT] = 1'b1;
            else if (rst)
                state_next[INIT] = 1'b1;
        state[NEXT]:
            if (in2)
                state_next[DONE] = 1'b1;
            else if (rst)
                state_next[INIT] = 1'b1;
            else
                state_next[NEXT] = 1'b1;
        state[DONE]:
            out = 1;
            state_next[INIT] = 1'b1;
    endcase
end

always_ff @(posedge clk) begin
    out <= out_next;
    state <= next_state;
end
```

Conclusions:
------------
## Best state machine:
Use method (1) or (3)! Quartus detects this as a state machine and implements minimal logic!!!  
If this works, you should fine the state machine listed in the compilation report under `Analysis & Synthesis / State machine` section.
It seems that it doesn't matter what your actual encodings and state width is, once (and **if**) Quartus detects your state machine, it will
decide on optimal encoding for your state machine by its own. From my experiments, identical one-hot and binary encoded state machines produced two identical designs (size-wise).

## Next Best:
Method (4)  
This is the classical method used by ASIC designers. By this method, each state drives all the one-hot state bits, but checkling for the existing state requires only looking at the one-hot bit.

## Worst:
Method (2)
This method encodes a one-hot state machine, but the coding style is different enough that Quartus doesn't recognize it as such, and doesn't do any specific state -machine optimizations.

Additional factors:
-------------------
I have tried to check the effects on using `unique case` instead of plain `case` as well as different values for the `default:` clause.  

Unfortunately, The state machine I have explored had one basic non-typical flaw - it avoided an external reset signal.  
It probably relies on a default `'0` value for the state registers, and sets the `default` clause to catch this value for the initial state.  
A better approach might be to explicitly reset the state by an external reset signal, and set the state value to `'x` for unexpected values, as this might optimize better.  

On my experiments, setting teh default value to `'x` merely caused the state machine to malfunction.
Also, using `unique case` has not given any benefit in my case.
And one final tip, `unique0 case` is simply not recognized by Quartus.

Further work:
-------------
It is possible to encode binary state machines by manually encoding states using grey encoding, assigning neighbouring values to state transitions,
and similar output behavior. The sample state machine above is too simple for that, but a state machine that goes `A->B->C->D->A` could benefit from grey encoding,


