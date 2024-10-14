#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;

class LightShader : public BaseShader
{
private:
	struct LightBufferType
	{
		XMFLOAT4 diffuse;
		XMFLOAT3 direction;
		float padding;

		float lightType;
		XMFLOAT3 lightPos;

		XMFLOAT4 ambientLight;

		float spotlightAngleMin;
		float spotlightAngleMax;
		XMFLOAT2 padding2;
	};

public:
	LightShader(ID3D11Device* device, HWND hwnd);
	~LightShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX &world, const XMMATRIX &view, const XMMATRIX &projection, ID3D11ShaderResourceView* texture, Light* light, XMFLOAT4 ambient);

private:
	void initShader(const wchar_t* cs, const wchar_t* ps);

private:
	ID3D11Buffer * matrixBuffer;
	ID3D11SamplerState* sampleState;
	ID3D11Buffer* lightBuffer;
};

