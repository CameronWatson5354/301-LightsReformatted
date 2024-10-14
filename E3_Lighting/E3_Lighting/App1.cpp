// Lab1.cpp
// Lab 1 example, simple coloured triangle mesh
#include "App1.h"

App1::App1()
{
	mesh = nullptr;
	shader = nullptr;
}

void App1::init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input *in, bool VSYNC, bool FULL_SCREEN)
{
	// Call super/parent init function (required!)
	BaseApplication::init(hinstance, hwnd, screenWidth, screenHeight, in, VSYNC, FULL_SCREEN);

	// Load texture
	textureMgr->loadTexture(L"brick", L"res/brick1.dds");

	// Create Mesh object and shader object
	mesh = new SphereMesh(renderer->getDevice(), renderer->getDeviceContext());
	shader = new LightShader(renderer->getDevice(), hwnd);

	planeMesh = new PlaneMesh(renderer->getDevice(), renderer->getDeviceContext());
	
	// Initialise light
	light = new Light();
	light->setDiffuseColour(1.0f, 1.0f, 1.0f, 1.0f);
	light->setDirection(1.0f, 0.0f, 0.0f);

	lightMesh = new SphereMesh(renderer->getDevice(), renderer->getDeviceContext());

	ambientLight = XMFLOAT4(0.1f, 0.1f, 0.1f, 1.0f);

	//light variables
	lightType = 0;
	lightPos = XMFLOAT3(0, 0, 0);
	lightDirection = XMFLOAT3(0.0f, -1.0f, 0.0f);
}


App1::~App1()
{
	// Run base application deconstructor
	BaseApplication::~BaseApplication();

	// Release the Direct3D object.
	if (mesh)
	{
		delete mesh;
		mesh = 0;
	}

	if (shader)
	{
		delete shader;
		shader = 0;
	}
}


bool App1::frame()
{
	bool result;

	result = BaseApplication::frame();
	if (!result)
	{
		return false;
	}
	
	// Render the graphics.
	result = render();
	if (!result)
	{
		return false;
	}

	return true;
}

bool App1::render()
{
	XMMATRIX worldMatrix, viewMatrix, projectionMatrix;

	// Clear the scene. (default blue colour)
	renderer->beginScene(0.39f, 0.58f, 0.92f, 1.0f);

	// Generate the view matrix based on the camera's position.
	camera->update();

	// Get the world, view, projection, and ortho matrices from the camera and Direct3D objects.
	worldMatrix = renderer->getWorldMatrix();
	viewMatrix = camera->getViewMatrix();
	projectionMatrix = renderer->getProjectionMatrix();

	//update light values
	light->setLightType(lightType);
	light->setPosition(lightPos.x, lightPos.y, lightPos.z);
	light->setDirection(lightDirection.x, lightDirection.y, lightDirection.z);


	light->setSpotlightAngleMin(spotlightAngleMin);
	light->setSpotlightAngleMax(spotlightAngleMax);

	if (spotlightAngleMax >= spotlightAngleMin && spotlightAngleMin > 0.01)
	{
		spotlightAngleMax = spotlightAngleMin - 0.01;
	}



	// Send geometry data, set shader parameters, render object with shader - render sphere
	mesh->sendData(renderer->getDeviceContext());
	shader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"brick"), light, ambientLight);
	shader->render(renderer->getDeviceContext(), mesh->getIndexCount());

	//plane mesh
	planeMesh->sendData(renderer->getDeviceContext());
	shader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"brick"), light, ambientLight);
	shader->render(renderer->getDeviceContext(), planeMesh->getIndexCount());

	//render light shape
	if (light->getHasMesh())
	{
		worldMatrix = worldMatrix * XMMatrixScaling(0.5, 0.5, 0.5);
		worldMatrix = worldMatrix * XMMatrixTranslation(lightPos.x, lightPos.y, lightPos.z);
		

		lightMesh->sendData(renderer->getDeviceContext());
		shader->setShaderParameters(renderer->getDeviceContext(), worldMatrix, viewMatrix, projectionMatrix, textureMgr->getTexture(L"brick"), light, ambientLight);
		shader->render(renderer->getDeviceContext(), lightMesh->getIndexCount());
	}

	

	// Render GUI
	gui();

	// Swap the buffers
	renderer->endScene();

	return true;
}

void App1::gui()
{
	// Force turn off unnecessary shader stages.
	renderer->getDeviceContext()->GSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->HSSetShader(NULL, NULL, 0);
	renderer->getDeviceContext()->DSSetShader(NULL, NULL, 0);

	// Build UI
	ImGui::Text("FPS: %.2f", timer->getFPS());
	ImGui::Checkbox("Wireframe mode", &wireframeToggle);

	ImGui::SliderInt("LightType", &lightType, 0, 2);

	switch (light->getLightType())
	{
	case 0: //directionale
		ImGui::SliderFloat3("Light Direction", (float*)&lightDirection, -1, 1);
		break;

	case 1: //point
		ImGui::SliderFloat3("Light Position", (float*)&lightPos, 0, 100);
		break;

	case 2: //spotlight
		ImGui::SliderFloat3("Light Position", (float*)&lightPos, 0, 100);
		ImGui::SliderFloat3("Light Direction", (float*)&lightDirection, -1, 1);
		ImGui::SliderFloat("Spotlight Angle Min", &spotlightAngleMin, 0, 90);
		ImGui::SliderFloat("Spotlight Angle Max", &spotlightAngleMax, 0, spotlightAngleMin - 0.01);
		break;
	}

	// Render UI
	ImGui::Render();
	ImGui_ImplDX11_RenderDrawData(ImGui::GetDrawData());
}

