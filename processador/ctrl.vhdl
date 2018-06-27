-- controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ctrl is
  port ( rst   : in STD_LOGIC;
         start : in STD_LOGIC;
         clk   : in STD_LOGIC;       
         imm   : out std_logic_vector(3 downto 0);
			alu_st: out std_logic_vector(1 downto 0) -- especifica qual operação deve ser feita com a ALU
			-- you will need to add more ports here as design grows
       );
end ctrl;

architecture fsm of ctrl is
  
  type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,done);
  signal state : state_type; 		

	-- constants declared for ease of reading code
	
	constant mova    : std_logic_vector(3 downto 0) := "0000";
	constant movr    : std_logic_vector(3 downto 0) := "0001";
	constant load    : std_logic_vector(3 downto 0) := "0010";
	constant add	  : std_logic_vector(3 downto 0) := "0011";
	constant sub	  : std_logic_vector(3 downto 0) := "0100";
	constant andr    : std_logic_vector(3 downto 0) := "0101";
	constant orr     : std_logic_vector(3 downto 0) := "0110";
	constant jmp	  : std_logic_vector(3 downto 0) := "0111";
	constant inv     : std_logic_vector(3 downto 0) := "1000";
	constant halt	  : std_logic_vector(3 downto 0) := "1001";


	-- Essa é a memória de instruções:
	-- as you add more code for your algorithms make sure to increase the
	-- array size. ie. 2 lines of code here, means array size of 0 to 1.
	type PM_BLOCK is array (0 to 1) of std_logic_vector(7 downto 0); -- PM é a memoria de instruções pelo que eu entendi
	constant PM : PM_BLOCK := (	

	-- This algorithm loads an immediate value of 3 and then stops
    "00100100",   -- load 4
	 "10011111"		-- halt
    );
  		 
begin
	process (clk)
	-- these variables declared here don't change.
	-- these are the only data allowed inside
	-- our otherwise pure FSM
  
	variable IR 		: std_logic_vector(7 downto 0);
	variable OPCODE 	: std_logic_vector( 3 downto 0);
	variable ADDRESS 	: std_logic_vector(3 downto 0);
	variable PC 		: integer;
    
	begin
		-- don't forget to take care of rst
    
		if (clk'event and clk = '1') then			
      
      --
      -- steady state
      --
    
      case state is
        
        when s0 =>    -- steady state
          PC := 0;
          imm <= "0000";
          if start = '1' then
            state <= s1;
          else 
            state <= s0;
          end if;
          
        when s1 =>				-- fetch instruction
          IR := PM(PC);
          OPCODE := IR(7 downto 4);
          ADDRESS:= IR(3 downto 0);
          state <= s2;
          
        when s2 =>				-- increment PC
          PC := PC + 1;
          state <= s3; 
          
          
        when s3 =>				-- decode instruction
          case OPCODE IS
				when mova => state <= s4;
				when movr => state <= s5;         
            when load => state <= s6;           -- notice we can use                                          
            when add =>  state <= s7;				-- the instruction          
				when sub =>  state <= s8;
				when andr => state <= s9;
				when orr => state <= s10;
				when jmp => state <= s11;
				when inv => state <= s12;
				when halt => state <= s13;
            when others =>
              state <= s1;
          end case;
        
			-- these states are the ones in which you actually
			-- start sending signals across
			-- to the datapath depending on what opcode is decoded.
			-- you add more states here.
        
		  when s4 => -- Accumulator = Register[dd]
		  
			 state <= s1;
		  when s5 => -- Register [dd] = Accumulator
		  
			 state <= s1;
        when s6 => --Accumulator = Immediate    -- load iiii
          imm <= address;                       -- set the immediate port
                                                -- to the lower_ir
          state <= s1;
		  when s7 => --Accumulator = Accumulator + Register[dd]
		  
			 state <= s1;	
		  when s8 => --Accumulator = Accumulator - Register[dd]
		  
			 state <= s1;
		  when s9 => --Accumulator = Accumulator AND Register[dd]
		  
			 state <= s1;
		  when s10 => --Accumulator = Accumulator OR Register[dd] 
		  
			 state <= s1;
		  when s11 => --PC = Address[aaaa] 
		  
			 state <= s1;
		  when s12 => --Accumulator = NOT Accumulator 
		  
			 state <= s1;
        when s13 =>  --Stop execution
          state <= s1;
          
        when done =>                            -- stay here forever
          state <= done;
          
        when others =>
          
      end case;
      
    end if;
  end process;				
end fsm;