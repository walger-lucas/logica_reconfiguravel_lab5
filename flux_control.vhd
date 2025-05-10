library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity flux_control is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    bram2_q : out std_logic_vector(7 downto 0)
  );
end entity;

architecture flux_control_arch of flux_control is

  signal slow_clk : std_logic;

  signal clk_div : integer;
  -- Sinais de controle para ambos os BRAMs
  signal write_en_bram1, write_en_bram2               : std_logic;
  signal addr_bram1, addr_bram2                       : std_logic_vector(10 downto 0);
  signal din_bram1, din_bram2                         : std_logic_vector(7 downto 0);
  signal dout_bram1                                   : std_logic_vector(7 downto 0);
  signal cnt_bram1, cnt_bram2                         : std_logic_vector(10 downto 0);
  signal readrq_fifo                                  : std_logic;
  signal empty_fifo, full_75_percent, full_50_percent : std_logic;
  signal write_en_fifo                                : std_logic;
  signal fifo_cnt, fifo_cnt_rd                        : std_logic_vector(9 downto 0);

  -- Sinais de estado para o controle do fluxo
  type write_state_type is (RESET, LOAD_BRAM1, WRITE_FIFO, WRITE_WAIT, WRITE_FINISH);
  type read_state_type is (RESET, READ_EMPTY_FIFO, READ_FIFO, READ_WAIT);
  signal write_state : write_state_type;
  signal read_state  : read_state_type;

begin

  process (clk, slow_clk, rst)
  begin
    if rst = '1' then
      write_state <= RESET;
      read_state <= RESET;
      write_en_bram1 <= '0';
      write_en_fifo <= '0';
      write_en_bram2 <= '0'; -- read enable da fifo tmb
      clk_div <= 0;
      slow_clk <= '0';
      addr_bram2 <= (others => '0');
      addr_bram1 <= (others => '0');
      cnt_bram1 <= (others => '0');
      cnt_bram2 <= (others => '0');
      din_bram1 <= (others => '0');
      readrq_fifo <= '0';

    else

      if rising_edge(clk) then
        case write_state is
          when RESET =>
            cnt_bram1 <= (others => '0');
            write_state <= LOAD_BRAM1;
          when LOAD_BRAM1 =>
            write_en_bram1 <= '1';
            din_bram1 <= std_logic_vector(to_unsigned(to_integer(unsigned(cnt_bram1)) mod 256, 8));
            addr_bram1 <= std_logic_vector(to_unsigned(to_integer(unsigned(cnt_bram1)), 11));

            if addr_bram1 = "11111111111" then
              write_en_bram1 <= '0';
              cnt_bram1 <= (others => '0');
              write_state <= WRITE_FIFO;
            else
              cnt_bram1 <= std_logic_vector(unsigned(cnt_bram1) + 1);
            end if;

          when WRITE_FIFO =>
            if full_75_percent = '1' then
              write_en_fifo <= '0';
              write_state <= WRITE_WAIT;
            else
              write_en_fifo <= '1';
              if addr_bram1 = "11111111111" then
                write_state <= WRITE_FINISH;
              else
                addr_bram1 <= std_logic_vector(unsigned(addr_bram1) + 1); -- signal is used as helper to write correct address in fifo
              end if;
            end if;
          when WRITE_WAIT =>
            if full_50_percent = '0' then
              write_state <= WRITE_FIFO;
            end if;
          when WRITE_FINISH =>
            write_en_fifo <= '0';
        end case;

        if (clk_div /= 6) then
          clk_div <= clk_div + 1;
          slow_clk <= '0';
        else
          slow_clk <= '1';
          clk_div <= 0;
        end if;

      end if;
      if rising_edge(slow_clk) then

        case read_state is
          when RESET =>
            cnt_bram2 <= (others => '0');
            if (empty_fifo = '1') then
              read_state <= READ_WAIT;
            else
              read_state <= READ_EMPTY_FIFO;
            end if;
          when READ_EMPTY_FIFO => -- read first part that is empty
            readrq_fifo <= '1';
            write_en_bram2 <= '0';
            read_state <= READ_FIFO;
          when READ_FIFO =>
            write_en_bram2 <= '1';
            if empty_fifo = '1' then
              read_state <= READ_WAIT;
              write_en_bram2 <= '0';
              readrq_fifo <= '0';
            end if;
            addr_bram2 <= std_logic_vector(to_unsigned(to_integer(unsigned(cnt_bram2)), 11));
            cnt_bram2 <= std_logic_vector(unsigned(cnt_bram2) + 1);
          when READ_WAIT =>
            if empty_fifo = '0' then
              read_state <= READ_EMPTY_FIFO;
            end if;
        end case;
      end if;
    end if;

  end process;

  full_50_percent <= fifo_cnt(9);                 -- if 512 bit is active then it is 50% full
  full_75_percent <= fifo_cnt(9) and fifo_cnt(8); -- if 512+256 bit is active then it is 75% full

  bram1: entity work.blockram2048
    port map (
      clk  => clk,
      we   => write_en_bram1,
      addr => addr_bram1,
      din  => din_bram1,
      dout => dout_bram1
    );

  bram2: entity work.blockram2048
    port map (
      clk  => slow_clk,
      we   => write_en_bram2,
      addr => addr_bram2,
      din  => din_bram2,
      dout => bram2_q
    );

  fifo: entity work.fifo_dual1024x8
    port map (
      aclr    => rst,
      data    => dout_bram1,
      rdclk   => slow_clk,
      rdreq   => readrq_fifo,
      wrclk   => clk,
      wrreq   => write_en_fifo,
      q       => din_bram2,
      rdempty => empty_fifo,
      rdusedw => fifo_cnt_rd,
      wrusedw => fifo_cnt
    );

end architecture;
