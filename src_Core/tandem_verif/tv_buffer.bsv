
package tv_buffer;

import Vector :: *;

typedef 80   TV_VB_SIZE;    // max bytes needed for each transaction
typedef  Vector #(TV_VB_SIZE, Bit#(8))  TVVecBytes;

typedef struct {
   Bit#(32)     num_bytes;
   TVVecBytes  vec_bytes;
} TVBuffer deriving (Bits, FShow);

endpackage