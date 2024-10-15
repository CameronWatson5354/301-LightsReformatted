#pragma once

#include "DXF.h"

using namespace std;
using namespace DirectX;

class LightShader : public BaseShader
{
private:
	struct LightBufferType
	{
		XMFLOAT4 diffuse[8];
		XMFLOAT4 direction[8];

		XMFLOAT4 lightType[8];
		XMFLOAT4 lightPos[8];

		XMFLOAT4 ambientLight;

		XMFLOAT4 spotlightAngleMin[8];
		XMFLOAT4 spotlightAngleMax[8];

		XMFLOAT4 specular[8];
		XMFLOAT4 specularPower[8];
	};

	struct CameraBufferType
	{
		XMFLOAT3 cameraPosition;
		float padding1;
	};

public:
	LightShader(ID3D11Device* device, HWND hwnd);
	~LightShader();

	void setShaderParameters(ID3D11DeviceContext* deviceContext, const XMMATRIX &world, const XMMATRIX &view, const XMMATRIX &projection, ID3D11ShaderResourceView* texture, Light* light[], XMFLOAT4 ambient, Camera* camera);

private:
	void initShader(const wchar_t* cs, const wchar_t* ps);

private:
	ID3D11Buffer * matrixBuffer;
	ID3D11SamplerState* sampleState;

	ID3D11Buffer* lightBuffer;
	ID3D11Buffer* cameraBuffer;

	int numOfLights = 8;

};

