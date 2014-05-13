/* Include files */

#include <stddef.h>
#include "blas.h"
#include "PDQuadrotor_integrator_sfun.h"
#include "c2_PDQuadrotor_integrator.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "PDQuadrotor_integrator_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c(sfGlobalDebugInstanceStruct,S);

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static const char * c2_debug_family_names[14] = { "kpx", "kdx", "kpy", "kdy",
  "nargin", "nargout", "STATE", "X", "XDOT", "Y", "YDOT", "K0", "u", "mode" };

/* Function Declarations */
static void initialize_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void initialize_params_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void enable_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void disable_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void c2_update_debugger_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static const mxArray *get_sim_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void set_sim_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance, const mxArray
   *c2_st);
static void finalize_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void sf_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void c2_chartstep_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void initSimStructsc2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void registerMessagesc2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber);
static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData);
static real_T c2_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_mode, const char_T *c2_identifier);
static real_T c2_b_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_c_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const char_T *c2_identifier, real_T c2_y
  [4]);
static void c2_d_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId,
  real_T c2_y[4]);
static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_e_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId,
  real_T c2_y[36]);
static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static void c2_eml_scalar_eg(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance);
static const mxArray *c2_e_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static int32_T c2_f_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static uint8_T c2_g_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_b_is_active_c2_PDQuadrotor_integrator, const
  char_T *c2_identifier);
static uint8_T c2_h_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void init_dsm_address_info(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  chartInstance->c2_sfEvent = CALL_EVENT;
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c2_is_active_c2_PDQuadrotor_integrator = 0U;
}

static void initialize_params_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  real_T c2_dv0[36];
  int32_T c2_i0;
  sf_set_error_prefix_string(
    "Error evaluating data 'K0' in the parent workspace.\n");
  sf_mex_import_named("K0", sf_mex_get_sfun_param(chartInstance->S, 0, 0),
                      c2_dv0, 0, 0, 0U, 1, 0U, 2, 4, 9);
  for (c2_i0 = 0; c2_i0 < 36; c2_i0++) {
    chartInstance->c2_K0[c2_i0] = c2_dv0[c2_i0];
  }

  sf_set_error_prefix_string("Stateflow Runtime Error (chart): ");
}

static void enable_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c2_update_debugger_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  const mxArray *c2_st;
  const mxArray *c2_y = NULL;
  real_T c2_hoistedGlobal;
  real_T c2_u;
  const mxArray *c2_b_y = NULL;
  int32_T c2_i1;
  real_T c2_b_u[4];
  const mxArray *c2_c_y = NULL;
  uint8_T c2_b_hoistedGlobal;
  uint8_T c2_c_u;
  const mxArray *c2_d_y = NULL;
  real_T *c2_mode;
  real_T (*c2_d_u)[4];
  c2_mode = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_d_u = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  c2_st = NULL;
  c2_st = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_createcellarray(3), FALSE);
  c2_hoistedGlobal = *c2_mode;
  c2_u = c2_hoistedGlobal;
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c2_y, 0, c2_b_y);
  for (c2_i1 = 0; c2_i1 < 4; c2_i1++) {
    c2_b_u[c2_i1] = (*c2_d_u)[c2_i1];
  }

  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 4), FALSE);
  sf_mex_setcell(c2_y, 1, c2_c_y);
  c2_b_hoistedGlobal = chartInstance->c2_is_active_c2_PDQuadrotor_integrator;
  c2_c_u = c2_b_hoistedGlobal;
  c2_d_y = NULL;
  sf_mex_assign(&c2_d_y, sf_mex_create("y", &c2_c_u, 3, 0U, 0U, 0U, 0), FALSE);
  sf_mex_setcell(c2_y, 2, c2_d_y);
  sf_mex_assign(&c2_st, c2_y, FALSE);
  return c2_st;
}

static void set_sim_state_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance, const mxArray
   *c2_st)
{
  const mxArray *c2_u;
  real_T c2_dv1[4];
  int32_T c2_i2;
  real_T *c2_mode;
  real_T (*c2_b_u)[4];
  c2_mode = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_b_u = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c2_doneDoubleBufferReInit = TRUE;
  c2_u = sf_mex_dup(c2_st);
  *c2_mode = c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u,
    0)), "mode");
  c2_c_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u, 1)), "u",
                        c2_dv1);
  for (c2_i2 = 0; c2_i2 < 4; c2_i2++) {
    (*c2_b_u)[c2_i2] = c2_dv1[c2_i2];
  }

  chartInstance->c2_is_active_c2_PDQuadrotor_integrator = c2_g_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell(c2_u, 2)),
     "is_active_c2_PDQuadrotor_integrator");
  sf_mex_destroy(&c2_u);
  c2_update_debugger_state_c2_PDQuadrotor_integrator(chartInstance);
  sf_mex_destroy(&c2_st);
}

static void finalize_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
}

static void sf_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  int32_T c2_i3;
  int32_T c2_i4;
  int32_T c2_i5;
  real_T *c2_X;
  real_T *c2_XDOT;
  real_T *c2_Y;
  real_T *c2_YDOT;
  real_T *c2_mode;
  real_T (*c2_STATE)[9];
  real_T (*c2_u)[4];
  c2_mode = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_YDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 4);
  c2_Y = (real_T *)ssGetInputPortSignal(chartInstance->S, 3);
  c2_XDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 2);
  c2_X = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c2_STATE = (real_T (*)[9])ssGetInputPortSignal(chartInstance->S, 0);
  c2_u = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
  for (c2_i3 = 0; c2_i3 < 4; c2_i3++) {
    _SFD_DATA_RANGE_CHECK((*c2_u)[c2_i3], 0U);
  }

  for (c2_i4 = 0; c2_i4 < 9; c2_i4++) {
    _SFD_DATA_RANGE_CHECK((*c2_STATE)[c2_i4], 1U);
  }

  _SFD_DATA_RANGE_CHECK(*c2_X, 2U);
  _SFD_DATA_RANGE_CHECK(*c2_XDOT, 3U);
  _SFD_DATA_RANGE_CHECK(*c2_Y, 4U);
  _SFD_DATA_RANGE_CHECK(*c2_YDOT, 5U);
  for (c2_i5 = 0; c2_i5 < 36; c2_i5++) {
    _SFD_DATA_RANGE_CHECK(chartInstance->c2_K0[c2_i5], 6U);
  }

  _SFD_DATA_RANGE_CHECK(*c2_mode, 7U);
  chartInstance->c2_sfEvent = CALL_EVENT;
  c2_chartstep_c2_PDQuadrotor_integrator(chartInstance);
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_PDQuadrotor_integratorMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
}

static void c2_chartstep_c2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
  real_T c2_hoistedGlobal;
  real_T c2_b_hoistedGlobal;
  real_T c2_c_hoistedGlobal;
  real_T c2_d_hoistedGlobal;
  int32_T c2_i6;
  real_T c2_STATE[9];
  real_T c2_X;
  real_T c2_XDOT;
  real_T c2_Y;
  real_T c2_YDOT;
  int32_T c2_i7;
  real_T c2_b_K0[36];
  uint32_T c2_debug_family_var_map[14];
  real_T c2_kpx;
  real_T c2_kdx;
  real_T c2_kpy;
  real_T c2_kdy;
  real_T c2_nargin = 6.0;
  real_T c2_nargout = 2.0;
  real_T c2_u[4];
  real_T c2_mode;
  real_T c2_b;
  real_T c2_y;
  real_T c2_b_b;
  real_T c2_b_y;
  real_T c2_c_b;
  real_T c2_c_y;
  real_T c2_d_b;
  real_T c2_d_y;
  int32_T c2_i8;
  real_T c2_a[36];
  real_T c2_e_y[9];
  int32_T c2_i9;
  real_T c2_e_b[9];
  int32_T c2_i10;
  int32_T c2_i11;
  int32_T c2_i12;
  real_T c2_C[4];
  int32_T c2_i13;
  int32_T c2_i14;
  int32_T c2_i15;
  int32_T c2_i16;
  int32_T c2_i17;
  int32_T c2_i18;
  int32_T c2_i19;
  real_T *c2_b_X;
  real_T *c2_b_XDOT;
  real_T *c2_b_Y;
  real_T *c2_b_YDOT;
  real_T *c2_b_mode;
  real_T (*c2_b_u)[4];
  real_T (*c2_b_STATE)[9];
  c2_b_mode = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_b_YDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 4);
  c2_b_Y = (real_T *)ssGetInputPortSignal(chartInstance->S, 3);
  c2_b_XDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 2);
  c2_b_X = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c2_b_STATE = (real_T (*)[9])ssGetInputPortSignal(chartInstance->S, 0);
  c2_b_u = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
  c2_hoistedGlobal = *c2_b_X;
  c2_b_hoistedGlobal = *c2_b_XDOT;
  c2_c_hoistedGlobal = *c2_b_Y;
  c2_d_hoistedGlobal = *c2_b_YDOT;
  for (c2_i6 = 0; c2_i6 < 9; c2_i6++) {
    c2_STATE[c2_i6] = (*c2_b_STATE)[c2_i6];
  }

  c2_X = c2_hoistedGlobal;
  c2_XDOT = c2_b_hoistedGlobal;
  c2_Y = c2_c_hoistedGlobal;
  c2_YDOT = c2_d_hoistedGlobal;
  for (c2_i7 = 0; c2_i7 < 36; c2_i7++) {
    c2_b_K0[c2_i7] = chartInstance->c2_K0[c2_i7];
  }

  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 14U, 14U, c2_debug_family_names,
    c2_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_kpx, 0U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_kdx, 1U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_kpy, 2U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_kdy, 3U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargin, 4U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargout, 5U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c2_STATE, 6U, c2_d_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_X, 7U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_XDOT, 8U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Y, 9U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_YDOT, 10U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_b_K0, 11U, c2_c_sf_marshallOut,
    c2_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c2_u, 12U, c2_b_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_mode, 13U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 3);
  c2_kpx = 6.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 4);
  c2_kdx = 48.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 5);
  c2_kpy = 6.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 6);
  c2_kdy = 48.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 7);
  c2_b = c2_Y;
  c2_y = 6.0 * c2_b;
  c2_b_b = c2_YDOT;
  c2_b_y = 48.0 * c2_b_b;
  c2_c_b = c2_X;
  c2_c_y = -6.0 * c2_c_b;
  c2_d_b = c2_XDOT;
  c2_d_y = 48.0 * c2_d_b;
  for (c2_i8 = 0; c2_i8 < 36; c2_i8++) {
    c2_a[c2_i8] = -c2_b_K0[c2_i8];
  }

  c2_e_y[0] = c2_y + c2_b_y;
  c2_e_y[1] = c2_c_y - c2_d_y;
  c2_e_y[2] = 0.0;
  c2_e_y[3] = 0.0;
  c2_e_y[4] = 0.0;
  c2_e_y[5] = 0.0;
  c2_e_y[6] = 0.0;
  c2_e_y[7] = 0.0;
  c2_e_y[8] = 0.0;
  for (c2_i9 = 0; c2_i9 < 9; c2_i9++) {
    c2_e_b[c2_i9] = c2_STATE[c2_i9] - c2_e_y[c2_i9];
  }

  c2_eml_scalar_eg(chartInstance);
  c2_eml_scalar_eg(chartInstance);
  for (c2_i10 = 0; c2_i10 < 4; c2_i10++) {
    c2_u[c2_i10] = 0.0;
  }

  for (c2_i11 = 0; c2_i11 < 4; c2_i11++) {
    c2_u[c2_i11] = 0.0;
  }

  for (c2_i12 = 0; c2_i12 < 4; c2_i12++) {
    c2_C[c2_i12] = c2_u[c2_i12];
  }

  for (c2_i13 = 0; c2_i13 < 4; c2_i13++) {
    c2_u[c2_i13] = c2_C[c2_i13];
  }

  for (c2_i14 = 0; c2_i14 < 4; c2_i14++) {
    c2_C[c2_i14] = c2_u[c2_i14];
  }

  for (c2_i15 = 0; c2_i15 < 4; c2_i15++) {
    c2_u[c2_i15] = c2_C[c2_i15];
  }

  for (c2_i16 = 0; c2_i16 < 4; c2_i16++) {
    c2_u[c2_i16] = 0.0;
    c2_i17 = 0;
    for (c2_i18 = 0; c2_i18 < 9; c2_i18++) {
      c2_u[c2_i16] += c2_a[c2_i17 + c2_i16] * c2_e_b[c2_i18];
      c2_i17 += 4;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 9);
  c2_mode = 0.0;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, -9);
  _SFD_SYMBOL_SCOPE_POP();
  for (c2_i19 = 0; c2_i19 < 4; c2_i19++) {
    (*c2_b_u)[c2_i19] = c2_u[c2_i19];
  }

  *c2_b_mode = c2_mode;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c2_sfEvent);
}

static void initSimStructsc2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
}

static void registerMessagesc2_PDQuadrotor_integrator
  (SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber)
{
}

static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  real_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(real_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, FALSE);
  return c2_mxArrayOutData;
}

static real_T c2_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_mode, const char_T *c2_identifier)
{
  real_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_mode), &c2_thisId);
  sf_mex_destroy(&c2_mode);
  return c2_y;
}

static real_T c2_b_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  real_T c2_y;
  real_T c2_d0;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_d0, 1, 0, 0U, 0, 0U, 0);
  c2_y = c2_d0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_mode;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mode = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_mode), &c2_thisId);
  sf_mex_destroy(&c2_mode);
  *(real_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_i20;
  real_T c2_b_inData[4];
  int32_T c2_i21;
  real_T c2_u[4];
  const mxArray *c2_y = NULL;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  for (c2_i20 = 0; c2_i20 < 4; c2_i20++) {
    c2_b_inData[c2_i20] = (*(real_T (*)[4])c2_inData)[c2_i20];
  }

  for (c2_i21 = 0; c2_i21 < 4; c2_i21++) {
    c2_u[c2_i21] = c2_b_inData[c2_i21];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 1, 4), FALSE);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, FALSE);
  return c2_mxArrayOutData;
}

static void c2_c_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const char_T *c2_identifier, real_T c2_y
  [4])
{
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_u), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_u);
}

static void c2_d_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId,
  real_T c2_y[4])
{
  real_T c2_dv2[4];
  int32_T c2_i22;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), c2_dv2, 1, 0, 0U, 1, 0U, 1, 4);
  for (c2_i22 = 0; c2_i22 < 4; c2_i22++) {
    c2_y[c2_i22] = c2_dv2[c2_i22];
  }

  sf_mex_destroy(&c2_u);
}

static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_u;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[4];
  int32_T c2_i23;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_u = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_u), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_u);
  for (c2_i23 = 0; c2_i23 < 4; c2_i23++) {
    (*(real_T (*)[4])c2_outData)[c2_i23] = c2_y[c2_i23];
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_i24;
  int32_T c2_i25;
  int32_T c2_i26;
  real_T c2_b_inData[36];
  int32_T c2_i27;
  int32_T c2_i28;
  int32_T c2_i29;
  real_T c2_u[36];
  const mxArray *c2_y = NULL;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_i24 = 0;
  for (c2_i25 = 0; c2_i25 < 9; c2_i25++) {
    for (c2_i26 = 0; c2_i26 < 4; c2_i26++) {
      c2_b_inData[c2_i26 + c2_i24] = (*(real_T (*)[36])c2_inData)[c2_i26 +
        c2_i24];
    }

    c2_i24 += 4;
  }

  c2_i27 = 0;
  for (c2_i28 = 0; c2_i28 < 9; c2_i28++) {
    for (c2_i29 = 0; c2_i29 < 4; c2_i29++) {
      c2_u[c2_i29 + c2_i27] = c2_b_inData[c2_i29 + c2_i27];
    }

    c2_i27 += 4;
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 2, 4, 9), FALSE);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, FALSE);
  return c2_mxArrayOutData;
}

static void c2_e_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId,
  real_T c2_y[36])
{
  real_T c2_dv3[36];
  int32_T c2_i30;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), c2_dv3, 1, 0, 0U, 1, 0U, 2, 4, 9);
  for (c2_i30 = 0; c2_i30 < 36; c2_i30++) {
    c2_y[c2_i30] = c2_dv3[c2_i30];
  }

  sf_mex_destroy(&c2_u);
}

static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_K0;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y[36];
  int32_T c2_i31;
  int32_T c2_i32;
  int32_T c2_i33;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_b_K0 = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_K0), &c2_thisId, c2_y);
  sf_mex_destroy(&c2_b_K0);
  c2_i31 = 0;
  for (c2_i32 = 0; c2_i32 < 9; c2_i32++) {
    for (c2_i33 = 0; c2_i33 < 4; c2_i33++) {
      (*(real_T (*)[36])c2_outData)[c2_i33 + c2_i31] = c2_y[c2_i33 + c2_i31];
    }

    c2_i31 += 4;
  }

  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_d_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_i34;
  real_T c2_b_inData[9];
  int32_T c2_i35;
  real_T c2_u[9];
  const mxArray *c2_y = NULL;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  for (c2_i34 = 0; c2_i34 < 9; c2_i34++) {
    c2_b_inData[c2_i34] = (*(real_T (*)[9])c2_inData)[c2_i34];
  }

  for (c2_i35 = 0; c2_i35 < 9; c2_i35++) {
    c2_u[c2_i35] = c2_b_inData[c2_i35];
  }

  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 1, 9), FALSE);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, FALSE);
  return c2_mxArrayOutData;
}

const mxArray *sf_c2_PDQuadrotor_integrator_get_eml_resolved_functions_info(void)
{
  const mxArray *c2_nameCaptureInfo;
  c2_ResolvedFunctionInfo c2_info[9];
  c2_ResolvedFunctionInfo (*c2_b_info)[9];
  const mxArray *c2_m0 = NULL;
  int32_T c2_i36;
  c2_ResolvedFunctionInfo *c2_r0;
  c2_nameCaptureInfo = NULL;
  c2_nameCaptureInfo = NULL;
  c2_b_info = (c2_ResolvedFunctionInfo (*)[9])c2_info;
  (*c2_b_info)[0].context = "";
  (*c2_b_info)[0].name = "mtimes";
  (*c2_b_info)[0].dominantType = "double";
  (*c2_b_info)[0].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c2_b_info)[0].fileTimeLo = 1289541292U;
  (*c2_b_info)[0].fileTimeHi = 0U;
  (*c2_b_info)[0].mFileTimeLo = 0U;
  (*c2_b_info)[0].mFileTimeHi = 0U;
  (*c2_b_info)[1].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c2_b_info)[1].name = "eml_index_class";
  (*c2_b_info)[1].dominantType = "";
  (*c2_b_info)[1].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  (*c2_b_info)[1].fileTimeLo = 1323192178U;
  (*c2_b_info)[1].fileTimeHi = 0U;
  (*c2_b_info)[1].mFileTimeLo = 0U;
  (*c2_b_info)[1].mFileTimeHi = 0U;
  (*c2_b_info)[2].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c2_b_info)[2].name = "eml_scalar_eg";
  (*c2_b_info)[2].dominantType = "double";
  (*c2_b_info)[2].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  (*c2_b_info)[2].fileTimeLo = 1286840396U;
  (*c2_b_info)[2].fileTimeHi = 0U;
  (*c2_b_info)[2].mFileTimeLo = 0U;
  (*c2_b_info)[2].mFileTimeHi = 0U;
  (*c2_b_info)[3].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c2_b_info)[3].name = "eml_xgemm";
  (*c2_b_info)[3].dominantType = "char";
  (*c2_b_info)[3].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/eml_xgemm.m";
  (*c2_b_info)[3].fileTimeLo = 1299098372U;
  (*c2_b_info)[3].fileTimeHi = 0U;
  (*c2_b_info)[3].mFileTimeLo = 0U;
  (*c2_b_info)[3].mFileTimeHi = 0U;
  (*c2_b_info)[4].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/eml_xgemm.m";
  (*c2_b_info)[4].name = "eml_blas_inline";
  (*c2_b_info)[4].dominantType = "";
  (*c2_b_info)[4].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/eml_blas_inline.m";
  (*c2_b_info)[4].fileTimeLo = 1299098368U;
  (*c2_b_info)[4].fileTimeHi = 0U;
  (*c2_b_info)[4].mFileTimeLo = 0U;
  (*c2_b_info)[4].mFileTimeHi = 0U;
  (*c2_b_info)[5].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xgemm.m!below_threshold";
  (*c2_b_info)[5].name = "mtimes";
  (*c2_b_info)[5].dominantType = "double";
  (*c2_b_info)[5].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c2_b_info)[5].fileTimeLo = 1289541292U;
  (*c2_b_info)[5].fileTimeHi = 0U;
  (*c2_b_info)[5].mFileTimeLo = 0U;
  (*c2_b_info)[5].mFileTimeHi = 0U;
  (*c2_b_info)[6].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xgemm.m";
  (*c2_b_info)[6].name = "eml_index_class";
  (*c2_b_info)[6].dominantType = "";
  (*c2_b_info)[6].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_index_class.m";
  (*c2_b_info)[6].fileTimeLo = 1323192178U;
  (*c2_b_info)[6].fileTimeHi = 0U;
  (*c2_b_info)[6].mFileTimeLo = 0U;
  (*c2_b_info)[6].mFileTimeHi = 0U;
  (*c2_b_info)[7].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xgemm.m";
  (*c2_b_info)[7].name = "eml_scalar_eg";
  (*c2_b_info)[7].dominantType = "double";
  (*c2_b_info)[7].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_scalar_eg.m";
  (*c2_b_info)[7].fileTimeLo = 1286840396U;
  (*c2_b_info)[7].fileTimeHi = 0U;
  (*c2_b_info)[7].mFileTimeLo = 0U;
  (*c2_b_info)[7].mFileTimeHi = 0U;
  (*c2_b_info)[8].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/external/eml_blas_xgemm.m";
  (*c2_b_info)[8].name = "eml_refblas_xgemm";
  (*c2_b_info)[8].dominantType = "char";
  (*c2_b_info)[8].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/blas/refblas/eml_refblas_xgemm.m";
  (*c2_b_info)[8].fileTimeLo = 1299098374U;
  (*c2_b_info)[8].fileTimeHi = 0U;
  (*c2_b_info)[8].mFileTimeLo = 0U;
  (*c2_b_info)[8].mFileTimeHi = 0U;
  sf_mex_assign(&c2_m0, sf_mex_createstruct("nameCaptureInfo", 1, 9), FALSE);
  for (c2_i36 = 0; c2_i36 < 9; c2_i36++) {
    c2_r0 = &c2_info[c2_i36];
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->context, 15,
      0U, 0U, 0U, 2, 1, strlen(c2_r0->context)), "context", "nameCaptureInfo",
                    c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->name, 15, 0U,
      0U, 0U, 2, 1, strlen(c2_r0->name)), "name", "nameCaptureInfo", c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->dominantType,
      15, 0U, 0U, 0U, 2, 1, strlen(c2_r0->dominantType)), "dominantType",
                    "nameCaptureInfo", c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->resolved, 15,
      0U, 0U, 0U, 2, 1, strlen(c2_r0->resolved)), "resolved", "nameCaptureInfo",
                    c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->fileTimeLo,
      7, 0U, 0U, 0U, 0), "fileTimeLo", "nameCaptureInfo", c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->fileTimeHi,
      7, 0U, 0U, 0U, 0), "fileTimeHi", "nameCaptureInfo", c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->mFileTimeLo,
      7, 0U, 0U, 0U, 0), "mFileTimeLo", "nameCaptureInfo", c2_i36);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->mFileTimeHi,
      7, 0U, 0U, 0U, 0), "mFileTimeHi", "nameCaptureInfo", c2_i36);
  }

  sf_mex_assign(&c2_nameCaptureInfo, c2_m0, FALSE);
  sf_mex_emlrtNameCapturePostProcessR2012a(&c2_nameCaptureInfo);
  return c2_nameCaptureInfo;
}

static void c2_eml_scalar_eg(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance)
{
}

static const mxArray *c2_e_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(int32_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 6, 0U, 0U, 0U, 0), FALSE);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, FALSE);
  return c2_mxArrayOutData;
}

static int32_T c2_f_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  int32_T c2_y;
  int32_T c2_i37;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_i37, 1, 6, 0U, 0, 0U, 0);
  c2_y = c2_i37;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_sfEvent;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  int32_T c2_y;
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)chartInstanceVoid;
  c2_b_sfEvent = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_f_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_sfEvent),
    &c2_thisId);
  sf_mex_destroy(&c2_b_sfEvent);
  *(int32_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static uint8_T c2_g_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_b_is_active_c2_PDQuadrotor_integrator, const
  char_T *c2_identifier)
{
  uint8_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_h_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c2_b_is_active_c2_PDQuadrotor_integrator), &c2_thisId);
  sf_mex_destroy(&c2_b_is_active_c2_PDQuadrotor_integrator);
  return c2_y;
}

static uint8_T c2_h_emlrt_marshallIn(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance, const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  uint8_T c2_y;
  uint8_T c2_u0;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_u0, 1, 3, 0U, 0, 0U, 0);
  c2_y = c2_u0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void init_dsm_address_info(SFc2_PDQuadrotor_integratorInstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c2_PDQuadrotor_integrator_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(2892937372U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3414259552U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2263407829U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1680053871U);
}

mxArray *sf_c2_PDQuadrotor_integrator_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,5,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("3fHBr32fFREV4aiQk7kiuD");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,5,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(9);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,4,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,4,"type",mxType);
    }

    mxSetField(mxData,4,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(9);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxData);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,2,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c2_PDQuadrotor_integrator_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

static const mxArray *sf_get_sim_state_info_c2_PDQuadrotor_integrator(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x3'type','srcId','name','auxInfo'{{M[1],M[9],T\"mode\",},{M[1],M[4],T\"u\",},{M[8],M[0],T\"is_active_c2_PDQuadrotor_integrator\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 3, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c2_PDQuadrotor_integrator_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
    chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)
      ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _PDQuadrotor_integratorMachineNumber_,
           2,
           1,
           1,
           8,
           0,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           ssGetPath(S),
           (void *)S);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          init_script_number_translation(_PDQuadrotor_integratorMachineNumber_,
            chartInstance->chartNumber);
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_PDQuadrotor_integratorMachineNumber_,
             chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _PDQuadrotor_integratorMachineNumber_,
            chartInstance->chartNumber,
            0,
            0,
            0);
          _SFD_SET_DATA_PROPS(0,2,0,1,"u");
          _SFD_SET_DATA_PROPS(1,1,1,0,"STATE");
          _SFD_SET_DATA_PROPS(2,1,1,0,"X");
          _SFD_SET_DATA_PROPS(3,1,1,0,"XDOT");
          _SFD_SET_DATA_PROPS(4,1,1,0,"Y");
          _SFD_SET_DATA_PROPS(5,1,1,0,"YDOT");
          _SFD_SET_DATA_PROPS(6,10,0,0,"K0");
          _SFD_SET_DATA_PROPS(7,2,0,1,"mode");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,0,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,481);
        _SFD_TRANS_COV_WTS(0,0,0,1,0);
        if (chartAlreadyPresent==0) {
          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              0,NULL,NULL,
                              1,NULL,NULL,
                              0,NULL,NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshallOut,(MexInFcnForType)
            c2_b_sf_marshallIn);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 9;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_d_sf_marshallOut,(MexInFcnForType)NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(4,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(5,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);

        {
          unsigned int dimVector[2];
          dimVector[0]= 4;
          dimVector[1]= 9;
          _SFD_SET_DATA_COMPILED_PROPS(6,SF_DOUBLE,2,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_c_sf_marshallOut,(MexInFcnForType)
            c2_c_sf_marshallIn);
        }

        _SFD_SET_DATA_COMPILED_PROPS(7,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);

        {
          real_T *c2_X;
          real_T *c2_XDOT;
          real_T *c2_Y;
          real_T *c2_YDOT;
          real_T *c2_mode;
          real_T (*c2_u)[4];
          real_T (*c2_STATE)[9];
          c2_mode = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
          c2_YDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 4);
          c2_Y = (real_T *)ssGetInputPortSignal(chartInstance->S, 3);
          c2_XDOT = (real_T *)ssGetInputPortSignal(chartInstance->S, 2);
          c2_X = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
          c2_STATE = (real_T (*)[9])ssGetInputPortSignal(chartInstance->S, 0);
          c2_u = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
          _SFD_SET_DATA_VALUE_PTR(0U, *c2_u);
          _SFD_SET_DATA_VALUE_PTR(1U, *c2_STATE);
          _SFD_SET_DATA_VALUE_PTR(2U, c2_X);
          _SFD_SET_DATA_VALUE_PTR(3U, c2_XDOT);
          _SFD_SET_DATA_VALUE_PTR(4U, c2_Y);
          _SFD_SET_DATA_VALUE_PTR(5U, c2_YDOT);
          _SFD_SET_DATA_VALUE_PTR(6U, chartInstance->c2_K0);
          _SFD_SET_DATA_VALUE_PTR(7U, c2_mode);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _PDQuadrotor_integratorMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "puNtWJKOCJlBM39v3cJzpC";
}

static void sf_opaque_initialize_c2_PDQuadrotor_integrator(void
  *chartInstanceVar)
{
  chart_debug_initialization(((SFc2_PDQuadrotor_integratorInstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c2_PDQuadrotor_integrator
    ((SFc2_PDQuadrotor_integratorInstanceStruct*) chartInstanceVar);
  initialize_c2_PDQuadrotor_integrator
    ((SFc2_PDQuadrotor_integratorInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c2_PDQuadrotor_integrator(void *chartInstanceVar)
{
  enable_c2_PDQuadrotor_integrator((SFc2_PDQuadrotor_integratorInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_disable_c2_PDQuadrotor_integrator(void *chartInstanceVar)
{
  disable_c2_PDQuadrotor_integrator((SFc2_PDQuadrotor_integratorInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_gateway_c2_PDQuadrotor_integrator(void *chartInstanceVar)
{
  sf_c2_PDQuadrotor_integrator((SFc2_PDQuadrotor_integratorInstanceStruct*)
    chartInstanceVar);
}

extern const mxArray* sf_internal_get_sim_state_c2_PDQuadrotor_integrator
  (SimStruct* S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c2_PDQuadrotor_integrator
    ((SFc2_PDQuadrotor_integratorInstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c2_PDQuadrotor_integrator();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_raw2high'.\n");
  }

  return plhs[0];
}

extern void sf_internal_set_sim_state_c2_PDQuadrotor_integrator(SimStruct* S,
  const mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c2_PDQuadrotor_integrator();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c2_PDQuadrotor_integrator
    ((SFc2_PDQuadrotor_integratorInstanceStruct*)chartInfo->chartInstance,
     mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static const mxArray* sf_opaque_get_sim_state_c2_PDQuadrotor_integrator
  (SimStruct* S)
{
  return sf_internal_get_sim_state_c2_PDQuadrotor_integrator(S);
}

static void sf_opaque_set_sim_state_c2_PDQuadrotor_integrator(SimStruct* S,
  const mxArray *st)
{
  sf_internal_set_sim_state_c2_PDQuadrotor_integrator(S, st);
}

static void sf_opaque_terminate_c2_PDQuadrotor_integrator(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc2_PDQuadrotor_integratorInstanceStruct*)
                    chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_PDQuadrotor_integrator_optimization_info();
    }

    finalize_c2_PDQuadrotor_integrator
      ((SFc2_PDQuadrotor_integratorInstanceStruct*) chartInstanceVar);
    utFree((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc2_PDQuadrotor_integrator
    ((SFc2_PDQuadrotor_integratorInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c2_PDQuadrotor_integrator(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c2_PDQuadrotor_integrator
      ((SFc2_PDQuadrotor_integratorInstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c2_PDQuadrotor_integrator(SimStruct *S)
{
  /* Actual parameters from chart:
     K0
   */
  const char_T *rtParamNames[] = { "K0" };

  ssSetNumRunTimeParams(S,ssGetSFcnParamsCount(S));

  /* registration for K0*/
  ssRegDlgParamAsRunTimeParam(S, 0, 0, rtParamNames[0], SS_DOUBLE);
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_PDQuadrotor_integrator_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,sf_get_instance_specialization(),infoStruct,
      2);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,sf_get_instance_specialization(),
                infoStruct,2,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      sf_get_instance_specialization(),infoStruct,2,
      "gatewayCannotBeInlinedMultipleTimes"));
    sf_update_buildInfo(S,sf_get_instance_specialization(),infoStruct,2);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 4, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,2,5);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,2,2);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=2; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 5; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,2);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(2268255569U));
  ssSetChecksum1(S,(3129008833U));
  ssSetChecksum2(S,(4226839432U));
  ssSetChecksum3(S,(1075316482U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c2_PDQuadrotor_integrator(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c2_PDQuadrotor_integrator(SimStruct *S)
{
  SFc2_PDQuadrotor_integratorInstanceStruct *chartInstance;
  chartInstance = (SFc2_PDQuadrotor_integratorInstanceStruct *)utMalloc(sizeof
    (SFc2_PDQuadrotor_integratorInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc2_PDQuadrotor_integratorInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.enableChart =
    sf_opaque_enable_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.mdlStart = mdlStart_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c2_PDQuadrotor_integrator;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->S = S;
  ssSetUserData(S,(void *)(&(chartInstance->chartInfo)));/* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  sf_opaque_init_subchart_simstructs(chartInstance->chartInfo.chartInstance);
  chart_debug_initialization(S,1);
}

void c2_PDQuadrotor_integrator_method_dispatcher(SimStruct *S, int_T method,
  void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c2_PDQuadrotor_integrator(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c2_PDQuadrotor_integrator(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c2_PDQuadrotor_integrator(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c2_PDQuadrotor_integrator_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
