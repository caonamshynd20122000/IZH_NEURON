/*
This version is forcing the uut.Pulse <=0
*/


`timescale 1ns/1ps

module TOP_NUMBER_tb;

    // Parameters
    localparam image_num = 9;
    localparam width = 31;
    localparam neuron_adr = 5;
    localparam weights = 31;
    localparam input_neuron_num = 58;
    localparam training_neuron_num = 10;
    localparam neuron_num = 68;

    // Inputs
    reg CLK = 0;
    reg RST = 0;
    reg BTN = 0;
    reg SEL = 0;
    reg [image_num:0] Image = 0;
    reg [neuron_num-input_neuron_num-1:0] Neuron = 0;

    // Outputs
    wire [neuron_num-input_neuron_num-1:0] Spikes_out;

    // Instantiate the Unit Under Test (UUT)
    TOP_NUMBER #(
        .IMAGE_NUM(image_num),
        .WIDTH(width),
        .NEURON_ADR(neuron_adr),
        .WEIGHTS(weights),
        .INPUT_NEURON_NUM(input_neuron_num),
        .TRAINING_NEURON_NUM(training_neuron_num),
        .NEURON_NUM(neuron_num)
    ) uut (
        .CLK(CLK),
        .RST(RST),
        .BTN(BTN),
        .SEL(SEL),
        .Image(Image),
        .Neuron(Neuron),
        .Spikes_out(Spikes_out)
    );

    // Clock generation
    always #5 CLK = ~CLK; // 10ns clock period

    // Stimulus
    initial begin
        // Reset
        RST = 1;
        #(5*10); // 5 cycles
        RST = 0;

        #(200_000); // wait 200us

        //Training Phase with BTN = 1
        train_image(0);
        train_image(1);
        train_image(2);
        train_image(3);
        train_image(4);
        train_image(5);
        train_image(6);
        train_image(7);
        train_image(8);
        train_image(9);
        // Testing with noise
        SEL = 1; // Use noisy image
        Neuron = 0;

        // test_image(0);
        // test_image(1);
        // test_image(2);
        // test_image(3);
        // test_image(4);
        // test_image(5);
        // test_image(6);
        // test_image(7);
        // test_image(8);
        // test_image(9);

        // // Reset and retrain or test again
        // Image = 0;
        // RST = 1;
        // #(20_000);
        // BTN = 1;
        // #(1000_000);
        // RST = 0;
        // BTN = 0;
        // Neuron = 0;

        // // Test phase again
        // test_image(0);
        // test_image(1);
        // test_image(2);
        // test_image(3);
        // test_image(4);
        // test_image(5);

        $finish;
    end

    // Tasks for training and testing
    task train_image(input integer idx);
    begin
        Image = 1 << idx;
        Neuron = 1 << idx;
        BTN = 1;
        #(10_000); // 10us
        BTN = 0;
        #(600_000); // 600us
    end
    endtask

    task test_image(input integer idx);
    begin
        Image = 1 << idx;
        #(400_000); // 400us
    end
    endtask

int counter_59 = 0;
int counter_60 = 0;
int counter_61 = 0;
int counter_62 = 0;
int counter_63 = 0;
int counter_64 = 0;
int counter_65 = 0;
int counter_66 = 0;
int counter_67 = 0;
int counter_68 = 0;

reg prev_match_59 = 0;
reg prev_match_60 = 0;
reg prev_match_61 = 0;
reg prev_match_62 = 0;
reg prev_match_63 = 0;
reg prev_match_64 = 0;
reg prev_match_65 = 0;
reg prev_match_66 = 0;
reg prev_match_67 = 0;
reg prev_match_68 = 0;

always @(posedge CLK) begin
    if (!prev_match_59 && uut.Training[59].TX.ADDR == 6'h30) begin
        counter_59 = counter_59 + 1;
        $display("At time %t: Addr[59] == 49", $time);
    end
    if (!prev_match_60 && uut.Training[60].TX.ADDR == 6'h30) begin
        counter_60 = counter_60 + 1;
        $display("At time %t: Addr[60] == 49", $time);
    end
    if (!prev_match_61 && uut.Training[61].TX.ADDR == 6'h30) begin
        counter_61 = counter_61 + 1;
        $display("At time %t: Addr[61] == 49", $time);
    end
    if (!prev_match_62 && uut.Training[62].TX.ADDR == 6'h30) begin
        counter_62 = counter_62 + 1;
        $display("At time %t: Addr[62] == 49", $time);
    end
    if (!prev_match_63 && uut.Training[63].TX.ADDR == 6'h30) begin
        counter_63 = counter_63 + 1;
        $display("At time %t: Addr[63] == 49", $time);
    end
    if (!prev_match_64 && uut.Training[64].TX.ADDR == 6'h30) begin
        counter_64 = counter_64 + 1;
        $display("At time %t: Addr[64] == 49", $time);
    end
    if (!prev_match_65 && uut.Training[65].TX.ADDR == 6'h30) begin
        counter_65 = counter_65 + 1;
        $display("At time %t: Addr[65] == 49", $time);
    end
    if (!prev_match_66 && uut.Training[66].TX.ADDR == 6'h30) begin
        counter_66 = counter_66 + 1;
        $display("At time %t: Addr[66] == 49", $time);
    end
    if (!prev_match_67 && uut.Training[67].TX.ADDR == 6'h30) begin
        counter_67 = counter_67 + 1;
        $display("At time %t: Addr[67] == 49", $time);
    end
    if (!prev_match_68 && uut.Training[68].TX.ADDR == 6'h30) begin
        counter_68 = counter_68 + 1;
        $display("At time %t: Addr[68] == 49", $time);
    end

    // Update prev_match flags
    prev_match_59 <= (uut.Training[59].TX.ADDR == 6'h30);
    prev_match_60 <= (uut.Training[60].TX.ADDR == 6'h30);
    prev_match_61 <= (uut.Training[61].TX.ADDR == 6'h30);
    prev_match_62 <= (uut.Training[62].TX.ADDR == 6'h30);
    prev_match_63 <= (uut.Training[63].TX.ADDR == 6'h30);
    prev_match_64 <= (uut.Training[64].TX.ADDR == 6'h30);
    prev_match_65 <= (uut.Training[65].TX.ADDR == 6'h30);
    prev_match_66 <= (uut.Training[66].TX.ADDR == 6'h30);
    prev_match_67 <= (uut.Training[67].TX.ADDR == 6'h30);
    prev_match_68 <= (uut.Training[68].TX.ADDR == 6'h30);
end

// Stop training when counter hits 6
always @(posedge CLK) begin
if (counter_59 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 59 stopped early at time %t due to counter == 6", $time);
    counter_59 = 0;
end

if (counter_60 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 60 stopped early at time %t due to counter == 6", $time);
    counter_60 = 0;
end

if (counter_61 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 61 stopped early at time %t due to counter == 6", $time);
    counter_61 = 0;
end

if (counter_62 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 62 stopped early at time %t due to counter == 6", $time);
    counter_62 = 0;
end

if (counter_63 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 63 stopped early at time %t due to counter == 6", $time);
    counter_63 = 0;
end

if (counter_64 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 64 stopped early at time %t due to counter == 6", $time);
    counter_64 = 0;
end

if (counter_65 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 65 stopped early at time %t due to counter == 6", $time);
    counter_65 = 0;
end

if (counter_66 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 66 stopped early at time %t due to counter == 6", $time);
    counter_66 = 0;
end

if (counter_67 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 67 stopped early at time %t due to counter == 6", $time);
    counter_67 = 0;
end

if (counter_68 == 6) begin
    uut.EN_STDP <= 1'b0;
    uut.EN_Pulse <= 1'b0;
    uut.Pulse <= 17'b0;
    $display("Training 68 stopped early at time %t due to counter == 6", $time);
    counter_68 = 0;
end

end


    initial begin
        $dumpfile("TOP_NUMBER_tb_all.vcd");
        $dumpvars(0,TOP_NUMBER_tb);
    end
endmodule
