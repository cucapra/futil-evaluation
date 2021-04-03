// MACRO DEF START

define(DATATYPE, ubit<32>)
define(ITER, ubit<8>)
define(N, 20)
define(N_1, decr(N))
define(TSTEPS, 20)
define(ZERO, 0)
define(ONE, 1)
define(TWO, 2)

// MACRO DEF END

decl u: DATATYPE[N][N];
decl v: DATATYPE[N][N];
decl p: DATATYPE[N][N];
decl q: DATATYPE[N][N];

let DX: DATATYPE = ONE / (N as DATATYPE);
let DY: DATATYPE = ONE / (N as DATATYPE);
let DT: DATATYPE = ONE / (TSTEPS as DATATYPE);
let B1: DATATYPE = TWO;
let B2: DATATYPE = ONE;

let mul1: DATATYPE = B1 * DT / (DX * DX);
let mul2: DATATYPE = B2 * DT / (DY * DY);

let a: DATATYPE = (0 - mul1) / TWO;
let b: DATATYPE = ONE + mul1;
let c: DATATYPE = a;
let d: DATATYPE = (0 - mul2) / TWO;
let e: DATATYPE = ONE + mul2;
let f: DATATYPE = d;

// DIFF: Original loop walks from 1 to TSTEPS but the iterator is never
// used.
for (let t: ITER = 0..TSTEPS) {

  // Column Sweep
  for (let i: ITER = 1..N_1) {
    v[0][i] := ONE;
    p[i][0] := ZERO;
    q[i][0] := ONE;

    ---

    for (let j: ITER = 1..N_1) {
      let p_i_j_1 = p[i][j-1];
      ---
      p[i][j] := (0-c) / (a*p_i_j_1+b);
      let u_j_i = u[j][i];
      ---
      let u_j_i_1 = u[j][i-1];
      ---
      let u_j_1_i = u[j][i+1];
      let q_i_j_1 = q[i][j-1];
      ---
      q[i][j] := ((0-d) * u_j_i_1 + (ONE+TWO*d) * u_j_i - f*u_j_1_i - a*q_i_j_1) / (a*p[i][j-1]+b);
    }

    v[(N_1 as DATATYPE)][i] := ONE;
    ---

    /*TODO: ORIGINAL: for (j=_PB_N-2; j>=1; j--) { }*/
    for (let j: ITER = rev 1..N_1) {
      let v_1_j_i = v[j+1][i];
      ---
      v[j][i] := p[i][j] * v_1_j_i + q[i][j];
    }
  }

  ---

  //Row Sweep
  for (let i: ITER = 1..N_1) {
    u[i][0] := ONE;
    p[i][0] := ZERO;
    q[i][0] := ONE;

    ---

    for (let j: ITER = 1..N_1) {
      let p_i_j_1 = p[i][j-1];
      let v_i_1_j = v[i-1][j];
      let q_i_j_1 = q[i][j-1];
      ---
      p[i][j] := (0-f) / (d*p_i_j_1+e);
      let v_1_i_j = v[i+1][j];
      ---
      q[i][j] := ((0-a) * v_i_1_j + (ONE+TWO*a)*v[i][j] - c*v_1_i_j-d*q_i_j_1)/(d*p[i][j-1]+e);
    }

    u[i][N_1] := ONE;
    ---
    for (let j: ITER = rev 1..N_1) {
      let u_i_1_j = u[i][j+1];
      ---
      u[i][j] := p[i][j] * u_i_1_j + q[i][j];
    }
  }

}
