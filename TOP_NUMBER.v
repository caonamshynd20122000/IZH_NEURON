/*
    - Phien ban hien tai: RST = 0 de training tiep tuc
    - Lap Neuron_WTA
*/

module TOP_NUMBER #(

    parameter                                               IMAGE_NUM           =   9,
    parameter                                               REST_TIME           =   149,
    parameter                                               TRAIN_TIME          =   412,
    parameter                                               TRAIN_SPIKE         =   10, //10 -> 9
    parameter                                               UNTRAIN_SPIKE       =   5, // 5 -> 4
    parameter                                               PRE_REG             =   15,
    parameter                                               POST_REG            =   5,
    parameter                                               WIDTH               =   31,
    parameter                                               NEURON_ADR          =   5,
    parameter                                               WEIGHTS             =   31,
    parameter                                               INPUT_NEURON_NUM    =   58,
    parameter                                               TRAINING_NEURON_NUM =   10,
    parameter                                               NEURON_NUM          =   68,
    parameter                                               DIFF_SPIKES         =   9
)(
    input                                                   CLK,
    input                                                   RST,
    input                                                   BTN,
    input                                                   SEL,
    input       [IMAGE_NUM:0]                               Image,
    input       [NEURON_NUM-INPUT_NEURON_NUM-1:0]           Neuron,
    output  reg [NEURON_NUM- INPUT_NEURON_NUM - 1:0]        Spikes_out
);



    // Internal Signals
    reg                                                     RST_Signal;
    reg         [IMAGE_NUM:0]                               Image_Signal;
    reg         [NEURON_NUM-INPUT_NEURON_NUM-1:0]           Neuron_Signal;
    reg         [NEURON_NUM-INPUT_NEURON_NUM-1:0]           Spikes_Signal;
    reg         [7:0]                                       Counter;
    wire        [INPUT_NEURON_NUM-TRAINING_NEURON_NUM:0]    Pixels, Digit, Digit_Noise;
    wire        [INPUT_NEURON_NUM:0]                        Spike_in;
    reg         [NEURON_NUM:0]                              Spikes;

    wire [NEURON_NUM:0]                                     All_Spikes; // 0 -> 46
    wire [NEURON_NUM:INPUT_NEURON_NUM - TRAINING_NEURON_NUM +1]                    Spike_connect; // 35 -> 46
    assign All_Spikes[INPUT_NEURON_NUM - TRAINING_NEURON_NUM:0] = Spikes[INPUT_NEURON_NUM - TRAINING_NEURON_NUM:0]; // 0 -> 34
    assign Spike_connect[INPUT_NEURON_NUM:INPUT_NEURON_NUM - TRAINING_NEURON_NUM +1] = Spikes[INPUT_NEURON_NUM:INPUT_NEURON_NUM - TRAINING_NEURON_NUM+1];


    wire        [NEURON_ADR:0]                              AER;
    wire                                                    EN_Neuron;

    typedef enum {NP, P0, P1}                               TYPES;
    TYPES                                                   STATE0, STATE1;

    //reg         [19:0]                                      BTN_Rebound;
    //reg                                                     BTN_Signal;
    reg                                                     EN_Pulse;
    reg         [16:0]                                      Pulse;
    reg                                                    EN_STDP;
    reg                                                    EN_Train;
    reg                                                     EN_Addr;
    wire        [NEURON_NUM:INPUT_NEURON_NUM+1]             WE;
    wire        [INPUT_NEURON_NUM-TRAINING_NEURON_NUM:0]    Pre_Spikes;

    wire        [9:0]                                       DIFF_SPIKE;

    reg         [NEURON_ADR:0]  Addr    [INPUT_NEURON_NUM+1:NEURON_NUM];
    reg         [WEIGHTS:0]     Weight  [INPUT_NEURON_NUM+1:NEURON_NUM];



    // RST Signal
    always @(posedge  CLK) begin
        if(RST) begin
            RST_Signal <=   1'b1;
        end
        else begin
            RST_Signal <=   1'b0;
        end
    end



    // Counter
    always @(posedge CLK) begin
        if(EN_Neuron) begin
            if(Counter == REST_TIME) begin
                Counter <= 8'd0;
            end
            else begin
                Counter <= Counter + 1;
            end
        end
    end



    // Input Neurons
    always @(posedge CLK) begin
        Image_Signal <= Image;
        Neuron_Signal <= Neuron;
    end


// Digit patterns

assign Digit =Image_Signal[0] ? 49'b001110001000100010001000100010001000100011100 :
              Image_Signal[1] ? 49'b000100001100100100001000010000100001000011100 :
              Image_Signal[2] ? 49'b001110001000010000010000100001000100010011111 :
              Image_Signal[3] ? 49'b001110001000010000010000011000000100001000111 :
              Image_Signal[4] ? 49'b000010000110010101001010011111100001000010000 :
              Image_Signal[5] ? 49'b011111001000000100000111100000010000010011100 :
              Image_Signal[6] ? 49'b000110001000000100000111100100010001000011100 :
              Image_Signal[7] ? 49'b011111000000100000100001000010001000100010000 :
              Image_Signal[8] ? 49'b001110001000100010000111000100010001000011100 :
              Image_Signal[9] ? 49'b001110001000100010000111100000100001000011100 :
              49'd0;


assign Digit_Noise =Image_Signal[0] ? 49'b001110001000100010001000100010001000100011100 :
                    Image_Signal[1] ? 49'b000100001100100100001000010000100001000011100 :
                    Image_Signal[2] ? 49'b001110001000010000010000100001000100010011111 :
                    Image_Signal[3] ? 49'b001110001000010000010000011000000100001000111 :
                    Image_Signal[4] ? 49'b000010000110010101001010011111100001000010000 :
                    Image_Signal[5] ? 49'b011111001000000100000111100000010000010011100 :
                    Image_Signal[6] ? 49'b000110001000000100000111100100010001000011100 :
                    Image_Signal[7] ? 49'b011111000000100000100001000010001000100010000 :
                    Image_Signal[8] ? 49'b001110001000100010000111000100010001000011100 :
                    Image_Signal[9] ? 49'b001110001000100010000111100000100001000011100 :
                    49'd0;

assign Pixels = SEL ?Digit_Noise : Digit;
assign Spike_in = {Neuron_Signal, Pixels};

genvar i;
// Input Neuron
generate
    for (i = 0; i <= INPUT_NEURON_NUM - TRAINING_NEURON_NUM; i = i + 1) begin
        always @(posedge CLK) begin
            if( Counter == REST_TIME) begin
                Spikes[i] <= Spike_in[i];
            end
            else begin
                Spikes[i] <= 1'b0;
            end
        end
    end
endgenerate

// STDP Change Synaptic Addr
always @(posedge CLK) begin
    if(Counter == REST_TIME-1) begin
        EN_Addr <= 1'b1;
    end
    else begin
        EN_Addr <= 1'b0;
    end
end

// Training Neurons

generate
    for(i = INPUT_NEURON_NUM - TRAINING_NEURON_NUM + 1; i <= INPUT_NEURON_NUM; i++) begin //49 - 58
        always @(posedge CLK) begin
            if(EN_STDP) begin
                if(Spike_in[i] && (Counter == TRAIN_SPIKE)) begin
                    Spikes[i] <= 1'b1;
                end
                else if ((!Spike_in[i]) && (Counter == REST_TIME - UNTRAIN_SPIKE)) begin
                    Spikes[i] <= 1'b1;
                end
                else begin
                    Spikes[i] <= 1'b0;
                end
            end
            else begin
                Spikes[i] <= 1'b0;
            end
        end
    end
endgenerate

// Output Spikes
always @(posedge CLK) begin
    Spikes_Signal <= Spikes[NEURON_NUM:INPUT_NEURON_NUM+1];
    Spikes_out <= Spike_connect[68:59];
end

assign Pre_Spikes = Spikes[INPUT_NEURON_NUM-TRAINING_NEURON_NUM:0]; // DONE !
assign EN_Train = EN_STDP && EN_Neuron;

    // Instance AER
    AER_BUS #(
        .NEURON_ADR(NEURON_ADR),
        .NEURON_NUM(NEURON_NUM)
    ) UUT_AER (
        .CLK(CLK),
        .SPIKES(All_Spikes),
        .EN_NEURON(EN_Neuron),
        .ADDR(AER)
    );

generate
    for (i = INPUT_NEURON_NUM + 1; i <= NEURON_NUM; i = i + 1) begin : Network
        wire [9:0] diff_spike;

        if (i == 59) begin
            assign diff_spike = {Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63], Spike_connect[64],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 60) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[61], Spike_connect[62], Spike_connect[63], Spike_connect[64],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 61) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[62], Spike_connect[63], Spike_connect[64],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 62) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[63], Spike_connect[64],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 63) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[64],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 64) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63],
                                 Spike_connect[65], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 65) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63],
                                 Spike_connect[64], Spike_connect[66], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 66) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63],
                                 Spike_connect[64], Spike_connect[65], Spike_connect[67], Spike_connect[68], 1'b0};
        end
        else if (i == 67) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63],
                                 Spike_connect[64], Spike_connect[65], Spike_connect[66], Spike_connect[68], 1'b0};
        end
        else if (i == 68) begin
            assign diff_spike = {Spike_connect[59], Spike_connect[60], Spike_connect[61], Spike_connect[62], Spike_connect[63],
                                 Spike_connect[64], Spike_connect[65], Spike_connect[66], Spike_connect[67], 1'b0};
        end

        IZH_NEURON #(
            .NUMBER(i),
            .WIDTH(WIDTH),
            .NEURON_ADR(NEURON_ADR),
            .WEIGHTS(WEIGHTS),
            .DIFF_SPIKES(DIFF_SPIKES)
        ) NX (
            .CLK(CLK),
            .RST(RST_Signal),
            .EN(EN_Neuron),
            .WE(WE[i]),
            .A(Addr[i]),
            .DPRA(AER),
            .DI(Weight[i]),
            .DIFF_SPIKE(diff_spike),
            .SPIKE(Spike_connect[i])
        );
    end
endgenerate


// STDP component
generate
    for (i = INPUT_NEURON_NUM+1; i <= NEURON_NUM; i = i+1) begin : Training 
        STDP #(
            .NEURON_ADR(NEURON_ADR),
            .WEIGHTS(WEIGHTS),
            .INPUT_NEURON_NUM(INPUT_NEURON_NUM),
            .TRAINING_NEURON_NUM(TRAINING_NEURON_NUM),
            .PRE_REG(PRE_REG),
            .POST_REG(POST_REG)
        ) TX (
            .CLK(CLK),
            .RST(RST_Signal),
            .EN(EN_Train),
            .EN_ADDR(EN_Addr),
            .PRE_SPIKES(Pre_Spikes),
            .POST_SPIKE(Spike_connect[i- TRAINING_NEURON_NUM]), // 35 -> 40
            .WE(WE[i]),
            .ADDR(Addr[i]),
            .WEIGHT(Weight[i])
        );
    end
endgenerate


// Enable signal for STDP module traning

always @(posedge CLK) begin
    if(BTN) begin
        EN_STDP <= 1'b1;
        EN_Pulse<= 1'b1;
    end
    else if (Pulse == TRAIN_TIME * REST_TIME) begin
        EN_STDP <= 1'b0;
        EN_Pulse<= 1'b0;
    end
end

// Counter 

always @(posedge CLK) begin
    if(EN_Neuron && EN_STDP) begin
        if(Pulse == TRAIN_TIME * REST_TIME) begin
            Pulse <= 17'd0;
        end
        else begin
            Pulse <= Pulse + 1;
        end
    end
end




endmodule : TOP_NUMBER