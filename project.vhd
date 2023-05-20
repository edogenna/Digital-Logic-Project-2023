----------------------------------------------------------------------------------
-- Prova Finale (Progetto di Reti Logiche)
-- Prof. Fabio Salice - Anno 2022/2023
--
-- Edoardo Gennaretti (Codice Persona 10743751 Matricola 955326)
-- Samuele Pietro Galli (Codice Persona 10710025 Matricola 955426) 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY project_reti_logiche IS
    PORT (
        i_clk      : IN  STD_LOGIC;
        i_rst      : IN  STD_LOGIC;
        i_start    : IN  STD_LOGIC;
        i_w        : IN  STD_LOGIC;
        o_z0       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_z1       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_z2       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_z3       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_done     : OUT STD_LOGIC;
        o_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        i_mem_data : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        o_mem_we   : OUT STD_LOGIC;
        o_mem_en   : OUT STD_LOGIC
    );
END project_reti_logiche;

ARCHITECTURE Behavioral OF project_reti_logiche IS
    SIGNAL reg_selector          : STD_LOGIC_VECTOR(1 DOWNTO 0)   := "00";
    SIGNAL reg_address           : STD_LOGIC_VECTOR (15 DOWNTO 0) := X"0000";
    SIGNAL reg_data_0            : STD_LOGIC_VECTOR (7 DOWNTO 0)  := X"00";
    SIGNAL reg_data_1            : STD_LOGIC_VECTOR (7 DOWNTO 0)  := X"00";
    SIGNAL reg_data_2            : STD_LOGIC_VECTOR (7 DOWNTO 0)  := X"00";
    SIGNAL reg_data_3            : STD_LOGIC_VECTOR (7 DOWNTO 0)  := X"00";

    SIGNAL shift_add             : STD_LOGIC                      := '0';
    SIGNAL reset_add             : STD_LOGIC                      := '0';
    SIGNAL enable_decoder        : STD_LOGIC                      := '0';

    SIGNAL reg_selector_lsb_load : STD_LOGIC                      := '0';
    SIGNAL reg_selector_msb_load : STD_LOGIC                      := '0';

    SIGNAL finished              : STD_LOGIC                      := '0';
    SIGNAL right_add             : STD_LOGIC                      := '0';
    SIGNAL overflow              : STD_LOGIC                      := '0';

    TYPE S IS (SEL_MSB, SEL_LSB, SHIFT, RIGHT, MEM, DONE, WRITE);
    SIGNAL cur_state, next_state : S;

BEGIN
    --elaborating the lsb bit of the selector
    PROCESS (i_clk, i_rst, reg_selector_lsb_load)
    BEGIN
        IF (i_rst = '1') THEN
            reg_selector(0) <= '0';
        ELSIF rising_edge(i_clk) AND reg_selector_lsb_load = '1' THEN
            reg_selector(0) <= i_w;
        END IF;
    END PROCESS;

    --elaborating the msb bit of the selector
    PROCESS (i_clk, i_rst, reg_selector_msb_load)
    BEGIN
        IF (i_rst = '1') THEN
            reg_selector(1) <= '0';
        ELSIF rising_edge(i_clk) AND reg_selector_msb_load = '1' THEN
            reg_selector(1) <= i_w;
        END IF;
    END PROCESS;

    --elaborating the RAM address
    PROCESS (i_clk, i_rst, reset_add, shift_add, right_add)
    BEGIN
        IF (i_rst = '1' OR reset_add = '1') THEN
            overflow    <= '0';
            reg_address <= X"0000";
        ELSIF rising_edge(i_clk) THEN
            IF (shift_add = '1') THEN
                overflow    <= reg_address(15);
                reg_address <= reg_address(14 DOWNTO 0) & i_w;
            ELSIF right_add = '1' THEN
                reg_address <= overflow & reg_address(15 DOWNTO 1);
            END IF;
        END IF;
    END PROCESS;

    --multiplexer for visualizing the saved data as soon the elaboration in completed
    WITH finished SELECT
        o_z0 <= "00000000" WHEN '0',
        reg_data_0 WHEN '1',
        "XXXXXXXX" WHEN OTHERS;

    WITH finished SELECT
        o_z1 <= "00000000" WHEN '0',
        reg_data_1 WHEN '1',
        "XXXXXXXX" WHEN OTHERS;

    WITH finished SELECT
        o_z2 <= "00000000" WHEN '0',
        reg_data_2 WHEN '1',
        "XXXXXXXX" WHEN OTHERS;

    WITH finished SELECT
        o_z3 <= "00000000" WHEN '0',
        reg_data_3 WHEN '1',
        "XXXXXXXX" WHEN OTHERS;
    o_mem_addr <= reg_address;

    --save the data read from the RAM in the right register
    PROCESS (i_clk, i_rst, enable_decoder, reg_selector)
    BEGIN
        IF (i_rst = '1') THEN
            reg_data_0 <= X"00";
            reg_data_1 <= X"00";
            reg_data_2 <= X"00";
            reg_data_3 <= X"00";
        ELSIF (rising_edge(i_clk) AND enable_decoder = '1') THEN
            IF (reg_selector = "00") THEN
                reg_data_0 <= i_mem_data;
            ELSIF reg_selector = "01" THEN
                reg_data_1 <= i_mem_data;
            ELSIF reg_selector = "10" THEN
                reg_data_2 <= i_mem_data;
            ELSIF reg_selector = "11" THEN
                reg_data_3 <= i_mem_data;
            END IF;
        END IF;
    END PROCESS;


    -----------
    --  FSM  --
    -----------

    --reset of the fsm
    PROCESS (i_clk, i_rst)
    BEGIN
        IF (i_rst = '1') THEN
            cur_state <= SEL_MSB;
        ELSIF rising_edge(i_clk) THEN
            cur_state <= next_state;
        END IF;
    END PROCESS;

    --changes of between states of the fsm
    PROCESS (cur_state, i_start)
    BEGIN
        next_state <= cur_state; --if not specified the state doesn't change
        CASE cur_state IS
            WHEN SEL_MSB =>
                IF i_start = '1' THEN
                    next_state <= SEL_LSB;
                END IF;
            WHEN SEL_LSB =>
                next_state <= SHIFT;
            WHEN SHIFT =>
                IF i_start = '0' THEN
                    next_state <= RIGHT;
                END IF;
            WHEN RIGHT =>
                next_state <= MEM;
            WHEN MEM =>
                next_state <= DONE;
            WHEN DONE =>
                next_state <= WRITE;
            WHEN WRITE =>
                next_state <= SEL_MSB;
        END CASE;
    END PROCESS;

    --signals for each state of the fsm
    PROCESS (cur_state)
    BEGIN
        --signals not specified are setted as 0
        shift_add             <= '0';
        enable_decoder        <= '0';
        reg_selector_lsb_load <= '0';
        reg_selector_msb_load <= '0';
        finished              <= '0';
        o_mem_en              <= '0';
        o_mem_we              <= '0';
        o_done                <= '0';
        right_add             <= '0';
        reset_add             <= '0';
        CASE cur_state IS
            WHEN SEL_MSB =>
                reset_add             <= '1';
                reg_selector_msb_load <= '1';
            WHEN SEL_LSB =>
                reg_selector_lsb_load <= '1';
            WHEN SHIFT =>
                shift_add <= '1';
            WHEN RIGHT =>
                right_add <= '1';
            WHEN MEM =>
                o_mem_en <= '1';
            WHEN DONE =>
                enable_decoder <= '1';
                finished       <= '1';
            WHEN WRITE =>
                finished  <= '1';
                o_done    <= '1';
                reset_add <= '1';
        END CASE;
    END PROCESS;

END Behavioral;