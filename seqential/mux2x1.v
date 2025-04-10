module mux2x1 (
    input  a,
    input  b,
    input  sel,
    output y
);
  wire not_sel, w1, w2;
  not (not_sel, sel);
  and (w1, a, not_sel);
  and (w2, b, sel);
  or (y, w1, w2);
endmodule