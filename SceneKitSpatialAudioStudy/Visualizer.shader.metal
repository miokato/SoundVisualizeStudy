//
//  Visualizer.shader.metal
//  SceneKitSpatialAudioStudy
//
//  Created by mio kato on 2021/04/10.
//

#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
};

vertex ColorInOut soundVertexShader(const device float4 *positions [[ buffer(0) ]],
                               uint vid [[ vertex_id ]])
{
    ColorInOut out;
    out.position = positions[vid];
    return out;
}

constant float sampleNum = 85; // 128だが、80まで使う。
constant float3 colorA = float3(0.149,0.341,0.912);
constant float3 colorB = float3(1.000,0.221,0.124);
constant float3 colorC = float3(0.210,0.981,0.124);
constant float3 whiteColor = float3(1.0, 1.0, 1.0);
fragment float4 soundFragmentShader(ColorInOut in [[ stage_in ]],
                               constant float *values [[ buffer(0) ]],
                               constant float &index [[ buffer(1) ]],
                               constant float &time [[ buffer(2) ]],
                               constant float2 &resolution [[ buffer(3) ]])
{
    // 座標設定
    float2 uv = in.position.xy / resolution.x;
    uv.y = 1.0 - uv.y;
    
    // 周波数ごとの強さを入力地として受け取り、x座標で分類する。
    int position = int(uv.x * sampleNum);

    // step(edge, value)なので、uv.xは0~1をとるため、x方向にvalueで分割する。
    float3 result = step(uv.x, 1/sampleNum);

    // 棒に色を加える
    result += colorA * uv.x;
    result += colorB * (1.0-uv.x);
    result += colorC * abs((0.5-uv.x));
    // y方向にどこまで描画するかは、座標毎に値による。
    result += step((1.0 - uv.y) * values[position], 0.01);
    
    return float4(result, 1.0);
}

