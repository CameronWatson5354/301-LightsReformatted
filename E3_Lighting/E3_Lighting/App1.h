// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes
#include "DXF.h"	// include dxframework
#include "LightShader.h"


class App1 : public BaseApplication
{
public:

	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);

	bool frame();

protected:
	bool render();
	void gui();

private:
	LightShader* shader;
	SphereMesh* mesh;
	PlaneMesh* planeMesh;

	int numOfLights = 8;
	Light* light[8];
	SphereMesh* lightMesh[8];

	XMFLOAT4 ambientLight;

	//imgui variables
	int currentLight;
	int lightType[8];
	XMFLOAT4 lightColour[8];
	XMFLOAT4 specularColour[8];
	float specularPower[8];
	XMFLOAT3 lightPos[8];
	XMFLOAT3 lightDirection[8];
	XMFLOAT2 spotlightAngles[8];

	float spotlightAngleMin[8];
	float spotlightAngleMax[2];
};

#endif