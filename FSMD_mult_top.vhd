library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seq_mult_top is
    port(
        clk, reset: in std_logic;
        top_start: in std_logic;
        top_a_in, top_b_in: in std_logic_vector(7 downto 0);

        top_ready: out std_logic;
        top_r: out std_logic_vector(15 downto 0)
    );
end seq_mult_top;

architecture arch of seq_mult_top is
    --declaration of seq_mult component
    component seq_mult is
        port(
            clk, reset: in std_logic;
            start: in std_logic;
            a_in, b_in: in std_logic_vector(7 downto 0);

            ready: out std_logic;
            r: out std_logic_vector(15 downto 0)
        );
    end component;

    constant WIDTH: integer := 8;
    --type state_type is (idle, ab0, load, op);
    -- declare your new state_type here;
    type state_type is (Idle, CheckMultReady, WaitMultDone);


    signal state_reg, state_next: state_type;

    signal mult_start: std_logic;
    signal mult_a_in: std_logic_vector(WIDTH-1 downto 0);
    signal mult_b_in: std_logic_vector(WIDTH-1 downto 0);

    signal mult_ready: std_logic;
    signal mult_r: std_logic_vector(2*WIDTH-1 downto 0);

begin
    -- instantiate the multiplier module
    seq_mult_unit: seq_mult
        port map(clk => clk, reset => reset, start => mult_start, a_in => mult_a_in, b_in => mult_b_in, ready => mult_ready, r => mult_r);
    
    -- state and data register
    process(clk, reset)
    begin
        if (reset = '1') then
            state_reg <= idle;
        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
        end if;
    end process;

    -- combinational circuit
    process (state_reg, mult_ready, top_start)
    begin
        --default value
        state_next <= state_reg;
        top_ready <= '0';
        mult_start <= '0';

        case state_reg is
            -- Write your VHDL code below
            when Idle =>
                top_ready <= '1';
                if (top_start = '1') then
                    state_next <= CheckMultReady;
                end if;

            when CheckMultReady =>
                if (mult_ready = '1') then
                    mult_start <= '1';
                    state_next <= WaitMultDone;
                end if;

            when WaitMultDone =>
                if (mult_ready = '1') then
                    state_next <= Idle;
                end if;
        end case;
    end process;

    -- Outside of the Next-state process block
    mult_a_in <= top_a_in;
    mult_b_in <= top_b_in;
    top_r <= mult_r;
end arch;