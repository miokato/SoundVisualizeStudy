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

float3 rgb2hsb(float3 c ){
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz),
                 float4(c.gb, K.xy),
                 step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r),
                 float4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
float3 hsb2rgb(float3 c ){
    float3 rgb = clamp(abs(fmod(c.x*6.0+float3(0.0,4.0,2.0),
                               6.0)-3.0)-1.0,
                       0.0,
                       1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(float3(1.0), rgb, c.y);
}

constant float sampleNum = 85; // 128だが、80まで使う。

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

    // 棒に色を加える HSV色空間で色相をオレンジから水色にグラデーションさせる
    result += hsb2rgb(float3((1.0-(uv.x+0.1)*0.5), 0.6, 1.0));

    // y方向にどこまで描画するかは、座標毎に値による。
    result += step((1.0 - uv.y) * values[position], 0.01);
    
    return float4(result, 1.0);
}

