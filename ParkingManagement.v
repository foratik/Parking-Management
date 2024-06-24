module parking_management (
    input clk,
    input reset,
    input car_entered,
    input is_uni_car_entered,
    input car_exited,
    input is_uni_car_exited,
    input [4:0] current_hour,
    output reg [8:0] uni_parked_car,
    output reg [8:0] parked_car,
    output reg [8:0] uni_vacated_space,
    output reg [8:0] vacated_space,
    output reg uni_is_vacated_space,
    output reg is_vacated_space
);

localparam MAX_UNI_CAPACITY = 500;
localparam MAX_TOTAL_CAPACITY = 700;
localparam BASE_FREE_CAPACITY = 200;

reg [8:0] total_free_capacity;

always @ (posedge clk or posedge reset) begin
    if (reset) begin
        uni_parked_car <= 0;
        parked_car <= 0;
        total_free_capacity <= BASE_FREE_CAPACITY;
    end else begin
        case (current_hour)
            5'd8: total_free_capacity <= BASE_FREE_CAPACITY;
            5'd9: total_free_capacity <= BASE_FREE_CAPACITY;
            5'd10: total_free_capacity <= BASE_FREE_CAPACITY;
            5'd11: total_free_capacity <= BASE_FREE_CAPACITY;
            5'd12: total_free_capacity <= BASE_FREE_CAPACITY;
            5'd13: total_free_capacity <= BASE_FREE_CAPACITY + 50;
            5'd14: total_free_capacity <= BASE_FREE_CAPACITY + 100;
            5'd15: total_free_capacity <= BASE_FREE_CAPACITY + 150;
            5'd16: total_free_capacity <= BASE_FREE_CAPACITY + 300;
            default: total_free_capacity <= BASE_FREE_CAPACITY;
        endcase
    end
end

always @ (posedge clk or posedge reset) begin
    if (reset) begin
        uni_parked_car <= 0;
        parked_car <= 0;
    end else begin
        if (car_entered) begin
            if (is_uni_car_entered) begin
                if (uni_parked_car < MAX_UNI_CAPACITY) begin
                    uni_parked_car <= uni_parked_car + 1;
                end
            end else begin
                if (parked_car < total_free_capacity) begin
                    parked_car <= parked_car + 1;
                end
            end
        end
        if (car_exited) begin
            if (is_uni_car_exited) begin
                if (uni_parked_car > 0) begin
                    uni_parked_car <= uni_parked_car - 1;
                end
            end else begin
                if (parked_car > 0) begin
                    parked_car <= parked_car - 1;
                end
            end
        end
    end
end

always @ (posedge clk or posedge reset) begin
    if (reset) begin
        uni_vacated_space <= MAX_UNI_CAPACITY;
        vacated_space <= total_free_capacity;
    end else begin
        uni_vacated_space <= MAX_UNI_CAPACITY - uni_parked_car;
        vacated_space <= total_free_capacity - parked_car;
        uni_is_vacated_space <= (uni_vacated_space > 0) ? 1'b1 : 1'b0;
        is_vacated_space <= (vacated_space > 0) ? 1'b1 : 1'b0;
    end
end

endmodule


module parking_management_tb;

reg clk, reset, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited;
reg [4:0] current_hour;
wire uni_is_vacated_space, is_vacated_space;
wire [8:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space;

parking_management uut (
    .clk(clk),
    .reset(reset),
    .car_entered(car_entered),
    .is_uni_car_entered(is_uni_car_entered),
    .car_exited(car_exited),
    .is_uni_car_exited(is_uni_car_exited),
    .current_hour(current_hour),
    .uni_parked_car(uni_parked_car),
    .parked_car(parked_car),
    .uni_vacated_space(uni_vacated_space),
    .vacated_space(vacated_space),
    .uni_is_vacated_space(uni_is_vacated_space),
    .is_vacated_space(is_vacated_space)
);

initial begin

    clk = 0;
    reset = 1;
    car_entered = 0;
    is_uni_car_entered = 0;
    car_exited = 0;
    is_uni_car_exited = 0;
    current_hour = 5'd8; // initialize start time at 8 AM

    $display("Time\tCurrent Hour\tCar Entered\tUni Car Entered\tCar Exited\tUni Car Exited\tUni Parked\tFree Parked\tUni Vacant\tFree Vacant\tUni Vacant Space\tFree Vacant Space");

    $monitor("%d\t%d\t%b\t%b\t%b\t%b\t%d\t%d\t%d\t%d\t%b\t%b",
        $time, current_hour, car_entered, is_uni_car_entered, car_exited, is_uni_car_exited,
        uni_parked_car, parked_car, uni_vacated_space, vacated_space, uni_is_vacated_space, is_vacated_space);

    #10;
    reset = 0;

    // Enter a university car at 8 AM
    car_entered = 1;
    is_uni_car_entered = 1;
    #10;
    car_entered = 0;

    // Enter a free capacity car at 8 AM
    car_entered = 1;
    is_uni_car_entered = 0;
    #10;
    car_entered = 0;

    // Exit a university car at 8 AM
    car_exited = 1;
    is_uni_car_exited = 1;
    #10;
    car_exited = 0;

    // Exit a free capacity car at 8 AM
    car_exited = 1;
    is_uni_car_exited = 0;
    #10;
    car_exited = 0;

    // Set time to 13 PM
    current_hour = 5'd13;
    #10;

    // Enter a free capacity car at 13 PM
    car_entered = 1;
    is_uni_car_entered = 0;
    #10;
    car_entered = 0;

    // Set time to 16 PM
    current_hour = 5'd16;
    #10;

    // Enter a free capacity car at 16 PM
    car_entered = 1;
    is_uni_car_entered = 0;
    #10;
    car_entered = 0;

    #100;
    $finish;
end

always #5 clk = ~clk;

endmodule
