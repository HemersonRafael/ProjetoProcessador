library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

-- Bloco de controle

entity ctrl is
	port ( 
		rst   : in STD_LOGIC;
		start : in STD_LOGIC;
		clk   : in STD_LOGIC;       
		imm   : out std_logic_vector(3 downto 0);	
		-- SINAIS PARA CONTROLAR O DATAPATHH
		alu_st_ctrl: out std_logic_vector(3 downto 0); -- especifica qual operacao deve ser feita com a ALU
		sel_rf_ctrl: out std_logic_vector(1 downto 0);  -- especifica qual registrador serao usado no rf 
		en_rf		  : out std_logic;						  -- Enable do rf
		en_acc	  : out std_logic 						  -- Enable do acc			
   );
end ctrl;

--Para carregas:
-- en_acc = 1, en_rf = 0, tem de passar um valor para acc, que Ã© o imm

architecture fsm of ctrl is
  
	type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,done);
	signal state : state_type; 		

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


	type PM_BLOCK is array (0 to 1) of std_logic_vector(7 downto 0); -- PM e a memoria de instrucoes 
	constant PM : PM_BLOCK := (	
		-- This algorithm loads an immediate value of 3 and then stops
		"00100100",   -- load 4
		"10011111"		-- halt
   );
	
	begin
		process (clk,rst)
		-- Registrador de instrucao atual
		variable IR 		: std_logic_vector(7 downto 0);
		-- Codigo de operacao
		variable OPCODE 	: std_logic_vector(3 downto 0);
		-- Endereco da instrucao
		variable ADDRESS 	: std_logic_vector(3 downto 0);
		-- Program counter (PC) e um contador para navegacao entre as instrucoes
		variable PC 		: integer;
		
		begin
			
			if(rst = '1') then
				state <= s0;
			elsif (clk'event and clk = '1') then
				
				case state is
				 	when s0 =>    -- estado de espera
						PC := 0;
						imm <= "0000";
						if start = '1' then
							state <= s1;
						else 
							state <= s0;
						end if; 
					when s1 =>				-- busca de instrucoes
						IR 		:= PM(PC);
						OPCODE 	:= IR(7 downto 4);
						ADDRESS	:= IR(3 downto 0);
						state 	<= s2;					 
					when s2 =>				-- incrementando PC
						PC 	:= PC + 1;
						state <= s3; 						
					when s3 =>				-- decodificao de instrucoes
						case OPCODE IS
							when mova 	=> state <= s4;
							when movr	=> state <= s5;         
							when load 	=> state <= s6;                                               
							when add  	=> state <= s7;			         
							when sub  	=> state <= s8;
							when andr 	=> state <= s9;
							when orr  	=> state <= s10;
							when jmp  	=> state <= s11;
							when inv  	=> state <= s12;
							when halt 	=> state <= done;
							when others => state <= s1;
						end case;
					when s4 => -- Accumulator = Register[dd]
						en_acc <= '0';
						en_rf  <= '1'; --Ativa que a saÃ­da do rf para ir para o acc 
						state  <= s1;
					when s5 => -- Register [dd] = Accumulator 
						sel_rf_ctrl <= ADDRESS(3 downto 2);
						en_acc <= '1'; -- Ativa que a saida do acc vÃ¡ para o rf
						en_rf <= '0';
						state <= s1;
					when s6 => --Accumulator = Immediate    
						imm <= address;
						en_acc <= '0';
						en_rf  <= '0';
						state <= s1;
					when s7 => --Accumulator = Accumulator + Register[dd]
						en_acc <= '1';
						en_rf <= '1';					 
						alu_st_ctrl <= "0011";					 
						state <= s1;	
					when s8 => --Accumulator = Accumulator - Register[dd]
						en_acc <= '1';
						en_rf <= '1';					 
						alu_st_ctrl <= "0100";			
						state <= s1;
				   when s9 => --Accumulator = Accumulator AND Register[dd]
				  		en_acc <= '1';
						en_rf <= '1';
						alu_st_ctrl <= "0101";
						state <= s1;
					when s10 => --Accumulator = Accumulator OR Register[dd] 
						en_acc <= '1';
						en_rf <= '1';
						alu_st_ctrl <= "0110";
						state <= s1;
					when s11 => --PC = Address
						ADDRESS := IR(7 downto 4);
						PC 		:= conv_integer(unsigned(ADDRESS));
						state 	<= s1;
					when s12 => --Accumulator = NOT Accumulator 
						en_acc <= '1';
						en_rf	 <= '1';
						alu_st_ctrl <= "1000";
						state <= s1;    
					when done =>                            -- stay here forever
						state <= done;					
					when others => 
						state <= s0;				  
				end case;
				
			end if;
			
		end process;
	 
	-- END BEGIN
end fsm;