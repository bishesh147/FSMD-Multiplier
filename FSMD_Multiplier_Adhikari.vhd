library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seq_mult is
    port(
        clk, reset: in std_logic;
        start: in std_logic;
        a_in, b_in: in std_logic_vector(7 downto 0);
        ready: out std_logic;
        r: out std_logic_vector(15 downto 0)
    );
end seq_mult;

architecture two_seg_arch of seq_mult is
    constant WIDTH: integer := 8;
    type state_type is (idle, ab0, load, op);
    signal state_reg, state_next: state_type;
    signal a_reg, a_next: unsigned(WIDTH-1 downto 0);
    signal n_reg, n_next: unsigned(WIDTH-1 downto 0);
    signal r_reg, r_next: unsigned(2*WIDTH-1 downto 0);
begin
-- state and data register
    process(clk, reset)
    begin
        if (reset = '1') then
            state_reg <= idle;
            a_reg <= (others => '0');
            n_reg <= (others => '0');
            r_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
            a_reg <= a_next;
            n_reg <= n_next;
            r_reg <= r_next;
        end if;
    end process;

    -- combinational circuit
    process(start, state_reg, a_reg, n_reg, r_reg, a_in, b_in, n_next)
    begin
        -- default value
        state_next <= state_reg;
        a_next <= a_reg;
        n_next <= n_reg;
        r_next <= r_reg;
        ready <='0';


        case state_reg is
            when idle =>
                if (start = '1') then
                    if (a_in = "00000000" or b_in = "00000000") then
                        state_next <= ab0;
                    else
                        state_next <= load;
                    end if;
                end if;
                ready <= '1';

        when ab0 =>
            a_next <= unsigned(a_in);
            n_next <= unsigned(b_in);
            r_next <= (others => '0');
            state_next <= idle;

        when load =>
            a_next <= unsigned(a_in);
            n_next <= unsigned(b_in);
            r_next <= (others => '0');
            state_next <= op;

        when op =>
            n_next <= n_reg - 1;
            r_next <= ("00000000" & a_reg) + r_reg;
            if (n_next = "00000000") then
                state_next <= idle;
            end if;
        end case;
    end process;
    r <= std_logic_vector(r_reg);
end two_seg_arch;