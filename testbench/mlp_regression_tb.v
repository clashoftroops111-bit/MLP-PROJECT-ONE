
`timescale 1ns/1ps

module mlp_regression_tb;

    reg clk;
    reg rst;
    reg start;

    wire [3:0] predicted_digit;
    wire done;

    // DUT
    mlp_top DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .predicted_digit(predicted_digit),
        .done(done)
    );

    // Clock
    always #5 clk = ~clk;

    // Regression configuration
    integer image_index;
    integer hidden_index;
    integer logit_index;
    integer input_index;

    // Expected reference data
    reg [7:0] expected_hidden [0:15];
    reg [25:0] expected_logits [0:9];

    // File paths
    reg [8*256-1:0] input_file;
    reg [8*256-1:0] hidden_file;
    reg [8*256-1:0] logits_file;

    // File existence checks
    integer input_fd;
    integer hidden_fd;
    integer logits_fd;

    // Prediction reference
    integer expected_prediction;
    integer best_index;

    // Simulation control
    integer cycles;
    integer timeout_flag;

    // Per-image error counters
    integer image_hidden_errors;
    integer image_logit_errors;
    integer image_prediction_errors;

    // Global error counters
    integer total_errors;
    integer hidden_errors;
    integer logit_errors;
    integer prediction_errors;
    integer timeout_errors;
    integer passed_images;

    // Temporary values
    reg [7:0] actual_hidden;
    reg [25:0] actual_logit;

    initial
    begin

        clk = 0;
        rst = 0;
        start = 0;

        total_errors = 0;
        hidden_errors = 0;
        logit_errors = 0;
        prediction_errors = 0;
        timeout_errors = 0;
        passed_images = 0;

        $display("==============================================");
        $display("       50 IMAGE MLP REGRESSION TEST");
        $display("==============================================");

        for (image_index = 0; image_index < 50;
             image_index = image_index + 1)
        begin

            // Reset per-image counters
            image_hidden_errors = 0;
            image_logit_errors = 0;
            image_prediction_errors = 0;
            timeout_flag = 0;

            // Generate correctly zero-padded filenames
            if (image_index < 10)
            begin
                $sformat(input_file,
                         "regression/image_00%0d/input.mem",
                         image_index);

                $sformat(hidden_file,
                         "regression/image_00%0d/expected_hidden.mem",
                         image_index);

                $sformat(logits_file,
                         "regression/image_00%0d/expected_logits.mem",
                         image_index);
            end
            else
            begin
                $sformat(input_file,
                         "regression/image_0%0d/input.mem",
                         image_index);

                $sformat(hidden_file,
                         "regression/image_0%0d/expected_hidden.mem",
                         image_index);

                $sformat(logits_file,
                         "regression/image_0%0d/expected_logits.mem",
                         image_index);
            end

            $display("");
            $display("----------------------------------------------");
            $display("Testing image %0d", image_index);
            $display("Input file:  %0s", input_file);
            $display("Hidden file: %0s", hidden_file);
            $display("Logits file: %0s", logits_file);

            // Check that all files exist before loading
            input_fd = $fopen(input_file, "r");
            hidden_fd = $fopen(hidden_file, "r");
            logits_fd = $fopen(logits_file, "r");

            if ((input_fd == 0) ||
                (hidden_fd == 0) ||
                (logits_fd == 0))
            begin
                $display("ERROR: One or more regression files are missing.");
                $display("Check the regression folder and ModelSim working directory.");

                if (input_fd != 0)
                    $fclose(input_fd);

                if (hidden_fd != 0)
                    $fclose(hidden_fd);

                if (logits_fd != 0)
                    $fclose(logits_fd);

                $display("Regression test aborted.");
                $finish;
            end

            $fclose(input_fd);
            $fclose(hidden_fd);
            $fclose(logits_fd);

            // Load this image into the DUT input memory
            $readmemh(input_file, DUT.FL1.fld1.IM1.mem);

            // Load expected reference values
            $readmemh(hidden_file, expected_hidden);
            $readmemh(logits_file, expected_logits);

            // Calculate expected prediction from reference logits.
            // Strict greater-than preserves the lowest index on ties.
            best_index = 0;

            for (logit_index = 1; logit_index < 10;
                 logit_index = logit_index + 1)
            begin
                if ($signed(expected_logits[logit_index]) >
                    $signed(expected_logits[best_index]))
                begin
                    best_index = logit_index;
                end
            end

            expected_prediction = best_index;

            // Reset DUT (active-low reset)
            start = 0;
            rst = 0;

            repeat (3)
                @(negedge clk);

            rst = 1;

            repeat (2)
                @(negedge clk);

            // Start inference
            start = 1;

            @(negedge clk);
            start = 0;

            // Wait for inference to finish
            cycles = 0;

            while ((done !== 1'b1) && (cycles < 50000))
            begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            // Timeout check
            if (done !== 1'b1)
            begin
                $display("ERROR: TIMEOUT on image %0d", image_index);

                timeout_flag = 1;
                timeout_errors = timeout_errors + 1;
                total_errors = total_errors + 1;
            end

            else
            begin

                $display("Inference completed in %0d cycles", cycles);

                // Compare all 16 hidden activations
                for (hidden_index = 0; hidden_index < 16;
                     hidden_index = hidden_index + 1)
                begin

                    actual_hidden =
                        DUT.FL1.fld1.Am1.mem[hidden_index];

                    if (actual_hidden !== expected_hidden[hidden_index])
                    begin
                        $display(
                            "HIDDEN MISMATCH: image=%0d neuron=%0d expected=%0d actual=%0d",
                            image_index,
                            hidden_index,
                            expected_hidden[hidden_index],
                            actual_hidden
                        );

                        hidden_errors = hidden_errors + 1;
                        image_hidden_errors = image_hidden_errors + 1;
                        total_errors = total_errors + 1;
                    end

                end

                // Compare all 10 logits
                for (logit_index = 0; logit_index < 10;
                     logit_index = logit_index + 1)
                begin

                    actual_logit =
                        DUT.SL1.sld1.lm1.mem[logit_index];

                    if (actual_logit !== expected_logits[logit_index])
                    begin
                        $display(
                            "LOGIT MISMATCH: image=%0d class=%0d expected=%0d actual=%0d",
                            image_index,
                            logit_index,
                            $signed(expected_logits[logit_index]),
                            $signed(actual_logit)
                        );

                        logit_errors = logit_errors + 1;
                        image_logit_errors = image_logit_errors + 1;
                        total_errors = total_errors + 1;
                    end

                end

                // Compare final predicted digit
                if (predicted_digit !== expected_prediction)
                begin
                    $display(
                        "PREDICTION MISMATCH: image=%0d expected=%0d actual=%0d",
                        image_index,
                        expected_prediction,
                        predicted_digit
                    );

                    prediction_errors = prediction_errors + 1;
                    image_prediction_errors = image_prediction_errors + 1;
                    total_errors = total_errors + 1;
                end

                // Count image as passed only if every check passed
                if ((image_hidden_errors == 0) &&
                    (image_logit_errors == 0) &&
                    (image_prediction_errors == 0))
                begin
                    passed_images = passed_images + 1;

                    $display("IMAGE %0d: PASS", image_index);
                end
                else
                begin
                    $display("IMAGE %0d: FAIL", image_index);
                    $display("Hidden errors:     %0d", image_hidden_errors);
                    $display("Logit errors:      %0d", image_logit_errors);
                    $display("Prediction errors: %0d", image_prediction_errors);
                end

            end

        end

        // Final regression report
        $display("");
        $display("==============================================");
        $display("          REGRESSION TEST SUMMARY");
        $display("==============================================");

        $display("Total images tested:  50");
        $display("Images passed:        %0d", passed_images);
        $display("Images failed:        %0d", 50 - passed_images);

        $display("----------------------------------------------");

        $display("Hidden activation errors: %0d", hidden_errors);
        $display("Logit errors:             %0d", logit_errors);
        $display("Prediction errors:        %0d", prediction_errors);
        $display("Timeout errors:           %0d", timeout_errors);

        $display("----------------------------------------------");
        $display("Total errors:             %0d", total_errors);

        if ((passed_images == 50) && (total_errors == 0))
        begin
            $display("");
            $display("==============================================");
            $display("     COMPLETE 50 IMAGE REGRESSION: PASSED");
            $display("==============================================");
        end
        else
        begin
            $display("");
            $display("==============================================");
            $display("     COMPLETE 50 IMAGE REGRESSION: FAILED");
            $display("==============================================");
        end

        $finish;

    end

endmodule

