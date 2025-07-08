
`timescale 1ns/1ps

module TOP_NUMBER_tb;

    // Parameters
    localparam image_num = 9;
    localparam width = 31;
    localparam neuron_adr = 7;
    localparam weights = 31;
    localparam input_neuron_num = 149;
    localparam training_neuron_num = 6;
    localparam neuron_num = 155;

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
         // train_image(0);
         // train_image(1);
         // train_image(2);
         // train_image(3);
         // train_image(4);
         // train_image(5);

        // train_image(0);
        // train_image(1);
        // train_image(2);
        // train_image(3);
        // train_image(4);
        // train_image(5);

        // train_image(0);
        // train_image(1);
        // train_image(2);
        // train_image(3);
        // train_image(4);
        // train_image(5);

        // train_image(0);
        // train_image(1);
        // train_image(2);
        // train_image(3);
        // train_image(4);
        // train_image(5);

        // train_image(0);
        // train_image(1);
        // train_image(2);
        // train_image(3);
        // train_image(4);
        // train_image(5);

        // train_image(0);
        // train_image(1);
        // train_image(2);
        // train_image(3);
        // train_image(4);
        // train_image(5);

        // Testing with noise
        SEL = 0; // Use noisy image
        Neuron = 0;

        test_image(0);
        test_image(1);
        test_image(2);
        test_image(3);
        test_image(4);
        test_image(5);
        
        // test_image(0);
        // test_image(2);
        // test_image(1);
        // test_image(5);

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
        #(900_000); // 600us
    end
    endtask

    task test_image(input integer idx);
    begin
        Image = 1 << idx;
        #(400_000); // 400us
    end
    endtask

int counter_150 = 0;
int counter_151 = 0;
int counter_152 = 0;
int counter_153 = 0;
int counter_154 = 0;
int counter_155 = 0;


reg prev_match_150 = 0;
reg prev_match_151 = 0;
reg prev_match_152 = 0;
reg prev_match_153 = 0;
reg prev_match_154 = 0;
reg prev_match_155 = 0;

always @(posedge CLK) begin
    if (!prev_match_150 && uut.Training[150].TX.ADDR == 8'd143) begin
        counter_150 = counter_150 + 1;
        $display("At time %t: Addr[150] == 144", $time);
    end
    if (!prev_match_151 && uut.Training[151].TX.ADDR == 8'd143) begin
        counter_151 = counter_151 + 1;
        $display("At time %t: Addr[151] == 144", $time);
    end
    if (!prev_match_152 && uut.Training[152].TX.ADDR == 8'd143) begin
        counter_152 = counter_152 + 1;
        $display("At time %t: Addr[152] == 144", $time);
    end
    if (!prev_match_153 && uut.Training[153].TX.ADDR == 8'd143) begin
        counter_153 = counter_153 + 1;
        $display("At time %t: Addr[154] == 144", $time);
    end
    if (!prev_match_154 && uut.Training[154].TX.ADDR == 8'd143) begin
        counter_154 = counter_154 + 1;
        $display("At time %t: Addr[154] == 144", $time);
    end
    if (!prev_match_155 && uut.Training[155].TX.ADDR == 8'd143) begin
        counter_155 = counter_155 + 1;
        $display("At time %t: Addr[155] == 144", $time);
    end

    // Update prev_match flags
    prev_match_150 <= (uut.Training[150].TX.ADDR == 8'd143);
    prev_match_151 <= (uut.Training[151].TX.ADDR == 8'd143);
    prev_match_152 <= (uut.Training[152].TX.ADDR == 8'd143);
    prev_match_153 <= (uut.Training[153].TX.ADDR == 8'd143);
    prev_match_154 <= (uut.Training[154].TX.ADDR == 8'd143);
    prev_match_155 <= (uut.Training[155].TX.ADDR == 8'd143);
end

// Stop training when counter hits 6
always @(posedge CLK) begin
    if (counter_150 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 150 stopped early at time %t due to counter == 6", $time);
        counter_150 = 0;
    end

    if (counter_151 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 151 stopped early at time %t due to counter == 6", $time);
        counter_151 = 0;
    end

    if (counter_152 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 152 stopped early at time %t due to counter == 6", $time);
        counter_152 = 0;
    end

    if (counter_153 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 153 stopped early at time %t due to counter == 6", $time);
        counter_153 = 0;
    end

    if (counter_154 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 154 stopped early at time %t due to counter == 6", $time);
        counter_154 = 0;
    end

    if (counter_155 == 2) begin
        uut.EN_STDP <= 1'b0;
        uut.EN_Pulse <= 1'b0;
        $display("Training 155 stopped early at time %t due to counter == 6", $time);
        counter_155 = 0;
    end
end


    initial begin
        $dumpfile("TOP_NUMBER_tb.vcd");
        $dumpvars(0,TOP_NUMBER_tb);
    end
endmodule
