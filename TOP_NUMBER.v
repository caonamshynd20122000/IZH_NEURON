    /*
        - Phien ban hien tai: RST = 0 de training tiep tuc
        - Lap Neuron_WTA
    */

    module TOP_NUMBER #(

        parameter                                               IMAGE_NUM           =   9,
        parameter                                               REST_TIME           =   149,
        parameter                                               TRAIN_TIME          =   912,
        parameter                                               TRAIN_SPIKE         =   10, //10 -> 9
        parameter                                               UNTRAIN_SPIKE       =   5, // 5 -> 4
        parameter                                               PRE_REG             =   15,
        parameter                                               POST_REG            =   5,
        parameter                                               WIDTH               =   31,
        parameter                                               NEURON_ADR          =   7,
        parameter                                               WEIGHTS             =   31,
        parameter                                               INPUT_NEURON_NUM    =   149,
        parameter                                               TRAINING_NEURON_NUM =   6,
        parameter                                               NEURON_NUM          =   155

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

        //wire        [4:0]                                       DIFF_SPIKE;

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

    assign Digit =Image_Signal[0] ? 144'b000000000000000000000000000000110000000111100000000100000000001111111000001100001100000000000100000000001000000000011000000001100000000000000000 : //3
                  Image_Signal[1] ? 144'b000000000000000000000000000000100000000000100000000000100000000001100000000001100000000001100000000001100000000001100000000000000000000000000000 : //135
                  Image_Signal[2] ? 144'b000000000000000000110000000001011000000010001000000000001000000000011000000111110000001001110000001111111000000100011000000000000000000000000000 : //147
                  Image_Signal[3] ? 144'b000000000000000000000000000000110000000011011000000000110000000001110000000000001000000000001000000100011000000100110000000011000000000000000000 : //90
                  Image_Signal[4] ? 144'b000000000000000000000000000000000000000001000000000010000000000010010000000100010000000011110000000000100000000000100000000000000000000000000000 : //109
                  Image_Signal[5] ? 144'b000000000000000000000000000000000000000111111100000110000000000111000000000000110000000000011000000000010000000000110000000111000000000000000000 : //102
                  Image_Signal[6] ? 144'b000000000000000000010000000000100000000001000000000000000000000010010000000010101000000011001000000001110000000000000000000000000000000000000000 : //81
                  Image_Signal[7] ? 144'b000000000000000000000000000000000000000111110000000011111000000000010000000000110000000001100000000001100000000001000000000001000000000000000000 : //86
                  Image_Signal[8] ? 144'b000000000000000000000000000000111000000001001000000001010000000001110000000001100000000010010000000100010000000111100000000000000000000000000000 : //110
                  Image_Signal[9] ? 144'b000000000000000000000000000000000000000011110000000110010000000100011000000100111000000011010000000000010000000000010000000000010000000000000000 :  //9
                  144'd0;


    assign Digit_Noise =Image_Signal[0] ? 144'b000000000000000000000000000000110000000111100000000100000000001111111000001100001100000000000100000000001000000000011000000001100000000000000000 : //3
                        Image_Signal[1] ? 144'b000000000000000000000000000000100000000000100000000000100000000001100000000001100000000001100000000001100000000001100000000000000000000000000000 : //135
                        Image_Signal[2] ? 144'b000000000000000000110000000001011000000010001000000000001000000000011000000111110000001001110000001111111000000100011000000000000000000000000000 : //147
                        Image_Signal[3] ? 144'b000000000000000000000000000000110000000011011000000000110000000001110000000000001000000000001000000100011000000100110000000011000000000000000000 : //90
                        Image_Signal[4] ? 144'b000000000000000000000000000000000000000001000000000010000000000010010000000100010000000011110000000000100000000000100000000000000000000000000000 : //109
                        Image_Signal[5] ? 144'b000000000000000000000000000000000000000111111100000110000000000111000000000000110000000000011000000000010000000000110000000111000000000000000000 : //102
                        Image_Signal[6] ? 144'b000000000000000000010000000000100000000001000000000000000000000010010000000010101000000011001000000001110000000000000000000000000000000000000000 : //81
                        Image_Signal[7] ? 144'b000000000000000000000000000000000000000111110000000011111000000000010000000000110000000001100000000001100000000001000000000001000000000000000000 : //86
                        Image_Signal[8] ? 144'b000000000000000000000000000000111000000001001000000001010000000001110000000001100000000010010000000100010000000111100000000000000000000000000000 : //110
                        Image_Signal[9] ? 144'b000000000000000000000000000000000000000011110000000110010000000100011000000100111000000011010000000000010000000000010000000000010000000000000000 :  //9
                        144'd0;

    assign Pixels = SEL ?   Digit_Noise : Digit;
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
        for(i = INPUT_NEURON_NUM - TRAINING_NEURON_NUM + 1; i <= INPUT_NEURON_NUM; i++) begin //FIXME: change from i < INPUT_NEURON_NUM to i <= INPUT_NEURON_NUM
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
        Spikes_out <= Spikes_Signal;
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
        for (i = INPUT_NEURON_NUM + 1; i <= NEURON_NUM; i = i + 1) begin : Network // 41 - 46
            wire [4:0] diff_spike;

            if (i == 41) begin
                assign diff_spike = {Spike_connect[46], Spike_connect[45], Spike_connect[44], Spike_connect[43], Spike_connect[42]};
            end
            else if (i == 42) begin
                assign diff_spike = {Spike_connect[46], Spike_connect[45], Spike_connect[44], Spike_connect[43], Spike_connect[41]};
            end
            else if (i == 43) begin
                assign diff_spike = {Spike_connect[46], Spike_connect[45], Spike_connect[44], Spike_connect[42], Spike_connect[41]};
            end
            else if (i == 44) begin
                assign diff_spike = {Spike_connect[46], Spike_connect[45], Spike_connect[43], Spike_connect[42], Spike_connect[41]};
            end
            else if (i == 45) begin
                assign diff_spike = {Spike_connect[46], Spike_connect[44], Spike_connect[43], Spike_connect[42], Spike_connect[41]};
            end
            else if (i == 46) begin
                assign diff_spike = {Spike_connect[45], Spike_connect[44], Spike_connect[43], Spike_connect[42], Spike_connect[41]};
            end

            IZH_NEURON #(
                .NUMBER(i),
                .WIDTH(WIDTH),
                .NEURON_ADR(NEURON_ADR),
                .WEIGHTS(WEIGHTS)
            ) NX (
                .CLK(CLK),
                .RST(RST_Signal),
                .EN(EN_Neuron),
                .WE(WE[i]),
                .A(Addr[i]),
                .DPRA(AER),
                .DI(Weight[i]),
                //.DIFF_SPIKE(diff_spike),
                .SPIKE(Spike_connect[i])
            );
        end
    endgenerate

    assign All_Spikes[NEURON_NUM:INPUT_NEURON_NUM+1] = Spike_connect[NEURON_NUM:INPUT_NEURON_NUM+1];

    // STDP component
    generate
        for (i = INPUT_NEURON_NUM+1; i <= NEURON_NUM; i = i+1) begin : Training // 150 - 155
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