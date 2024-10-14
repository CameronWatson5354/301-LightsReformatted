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


	Light* light[2];
	SphereMesh* lightMesh[2];

	XMFLOAT4 ambientLight;

	//imgui variables
	int currentLight;
	int lightType[2];
	XMFLOAT4 lightColour[2];
	XMFLOAT3 lightPos[2];
	XMFLOAT3 lightDirection[2];
	XMFLOAT2 spotlightAngles[2];

	float spotlightAngleMin[2];
	float spotlightAngleMax[2];
};

#endif