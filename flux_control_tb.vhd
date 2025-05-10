library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flux_control_tb is
end flux_control_tb;

architecture flux_control_tb_arch of flux_control_tb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';


begin

    uut: entity work.flux_control
        port map (
            clk => clk,
            rst => rst,
            bram2_q => open
        );

    -- Clock process
    clk_process : process
    begin
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;

    end process;

    -- Reset process
    rst_process : process
    begin
        rst <= '1';
        wait for 15 ns;
        rst <= '0';
        wait;
    end process;

end architecture;