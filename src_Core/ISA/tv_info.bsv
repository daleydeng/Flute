
package tv_info;

import Vector :: *;

typedef 80   TV_VB_SIZE;    // max bytes needed for each transaction
typedef  Vector #(TV_VB_SIZE, Bit#(8))  TV_Vec_Bytes;

typedef struct {
   Bit#(32)     num_bytes;
   TV_Vec_Bytes  vec_bytes;
} TV_Info deriving (Bits, FShow);

endpackage