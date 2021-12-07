#include <iostream>
#include <cassert>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/type_precision.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include "gl_core_3_3.h"
#include <GL/freeglut.h>
#include "util.hpp"
#include "mesh.hpp"
#include "imgui.h"
#include "imgui_impl_glut.h"
#include "imgui_impl_opengl3.h"
using namespace std;

// Stuff Stored in Texture
// Mass/Type, Time, XDir, YDir

// Global state
GLint width, height;				// Window size
int texWidth, texHeight;			// Texture size
vector<glm::vec4> initTexData;	// Initial texture data
GLuint prevTexture;		// Texture objects
GLuint currTexture;
GLuint gpgpuShader;		// Shader programs
GLuint dispShader;
GLuint fbo;				// Framebuffer object
GLuint uniXform;		// Shader location of xform mtx
GLuint vao;				// Vertex array object
GLuint vbuf;			// Vertex buffer
GLuint ibuf;			// Index buffer
GLuint uniClick;		// Shader Click Location
GLuint uniClicked;
GLuint uniType;
GLuint uniRand;
GLuint uniTime;
GLsizei vcount;			// Number of vertices
int nsteps = 10;		// Number of steps per frame
int updateTimer = 0;
glm::vec2 click;
int clicked;
float type;
float type_arr[10];
int idx;
int randNumber;
int timeSinceStart;

// ImGui States
static ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.70f, 1.00f);
bool toClearTexture;

// Constants
const int MENU_EXIT = 0;			// Exit application
const int MENU_SWITCH = 1;

// Initialization functions
void initState();
void initGLUT(int* argc, char** argv);
void initOpenGL();
void initGeometry();
void initTextures();

// Callback functions
void display();
void reshape(GLint width, GLint height);
void keyRelease(unsigned char key, int x, int y);
void mouseBtn(int button, int state, int x, int y);
void mouseMove(bool dragging, int x, int y);
void idle();
void menu(int cmd);
void cleanup();

// ImGui Functions
void my_display_code();
void clear_texture();

int main(int argc, char** argv) {
	try {
		// Initialize
		initState();
		initGLUT(&argc, argv);
		initOpenGL();
		initGeometry();
		initTextures();


		// Setup Dear ImGui context
		IMGUI_CHECKVERSION();
		ImGui::CreateContext();
		ImGuiIO& io = ImGui::GetIO(); (void)io;
		//io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls

		// Setup Dear ImGui style
		ImGui::StyleColorsDark();
		//ImGui::StyleColorsClassic();

		// Setup Platform/Renderer backends
		ImGui_ImplGLUT_Init();
		ImGui_ImplGLUT_InstallFuncs();
		ImGui_ImplOpenGL3_Init();
	} catch (const exception& e) {
		// Handle any errors
		cerr << "Fatal error: " << e.what() << endl;
		cleanup();
		return -1;
	}

	// Execute main loop
	glutMainLoop();

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGLUT_Shutdown();
    ImGui::DestroyContext();

	return 0;
}

void initState() {
	// Initialize global state
	width = 0;
	height = 0;
	texWidth = 128;
	texHeight = 128;
	prevTexture = 0;
	currTexture = 0;
	gpgpuShader = 0;
	dispShader = 0;
	fbo = 0;
	uniXform = 0;
	vao = 0;
	vbuf = 0;
	ibuf = 0;
	vcount = 0;
	clicked = 0;
	type = 1.0;
	//{ "Erase", "Block", "Steam", "Water", "Ice", "Plants", "Dirt", "Stone", "Magma", "Fire" };
	type_arr[0] = 0.0;
	type_arr[1] = 1000.0;
	type_arr[2] = 0.5;
	type_arr[3] = 1.0;
	type_arr[4] = 1.5;
	type_arr[5] = 1.25;
	type_arr[6] = 1.75;
	type_arr[7] = 3.0;
	type_arr[8] = 2.0;
	type_arr[9] = 0.3;
	idx = 0;
	randNumber = rand();
	timeSinceStart = 0;
	toClearTexture = false;
}

void initGLUT(int* argc, char** argv) {
	// Set window and context settings
	width = 800; height = 600;
	glutInit(argc, argv);
	glutInitWindowSize(width, height);
	glutInitContextVersion(3, 3);
	glutInitContextProfile(GLUT_CORE_PROFILE);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE);
	// Create the window
	glutCreateWindow("FreeGlut Window");

	// Create a menu
	// glutCreateMenu(menu);
	// glutAddMenuEntry("Next", MENU_SWITCH);
	// glutAddMenuEntry("Exit", MENU_EXIT);
	// glutAttachMenu(GLUT_RIGHT_BUTTON);

	// GLUT callbacks
	glutDisplayFunc(display);
	//glutReshapeFunc(reshape);
	//glutKeyboardUpFunc(keyRelease);
	//glutMouseFunc(mouseBtn);
	//glutMotionFunc(mouseMove);
	glutIdleFunc(idle);
	glutCloseFunc(cleanup);
}

void initOpenGL() {
	// Set clear color and depth
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClearDepth(1.0f);
	// Enable depth testing
	glEnable(GL_DEPTH_TEST);
	// Allow unpacking non-aligned pixel data
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	// Compile and link display shader
	vector<GLuint> shaders;
	shaders.push_back(compileShader(GL_VERTEX_SHADER, "sh_v_disp.glsl"));
	shaders.push_back(compileShader(GL_FRAGMENT_SHADER, "sh_f_disp.glsl"));
	dispShader = linkProgram(shaders);
	// Release shader sources
	for (auto s = shaders.begin(); s != shaders.end(); ++s)
		glDeleteShader(*s);
	shaders.clear();

	// Compile and link GPGPU shader
	shaders.push_back(compileShader(GL_VERTEX_SHADER, "sh_v_gpgpu.glsl"));
	shaders.push_back(compileShader(GL_FRAGMENT_SHADER, "sh_f_gpgpu.glsl"));
	gpgpuShader = linkProgram(shaders);
	// Release shader sources
	for (auto s = shaders.begin(); s != shaders.end(); ++s)
		glDeleteShader(*s);
	shaders.clear();

	// Locate uniforms
	uniXform = glGetUniformLocation(dispShader, "xform");

	// Bind texture image units
	GLuint uniTex = glGetUniformLocation(dispShader, "tex");
	glUseProgram(dispShader);
	glUniform1i(uniTex, 0);
	uniTex = glGetUniformLocation(gpgpuShader, "prevTex");
	uniClick = glGetUniformLocation(gpgpuShader, "click");
	uniClicked = glGetUniformLocation(gpgpuShader, "clicked");
	uniType = glGetUniformLocation(gpgpuShader, "type");
	uniRand = glGetUniformLocation(gpgpuShader, "randNumber");
	uniTime = glGetUniformLocation(gpgpuShader, "timeSinceStart");
	glUseProgram(gpgpuShader);
	glUniform1i(uniTex, 0);
	glUseProgram(0);

	assert(glGetError() == GL_NO_ERROR);
}

void initGeometry() {
	// Vertex format
	struct vert {
		glm::vec2 pos;
		glm::vec2 tc;
	};
	// Create a surface (quad) to draw the texture onto
	vector<vert> verts = {
		{ glm::vec2(-1.0f, -1.0f), glm::vec2(0.0f, 0.0f) },
		{ glm::vec2( 1.0f, -1.0f), glm::vec2(1.0f, 0.0f) },
		{ glm::vec2( 1.0f,  1.0f), glm::vec2(1.0f, 1.0f) },
		{ glm::vec2(-1.0f,  1.0f), glm::vec2(0.0f, 1.0f) },
	};
	// Vertex indices for triangles
	vector<GLuint> ids = {
		0, 1, 2,	// Triangle 1
		2, 3, 0		// Triangle 2
	};
	vcount = ids.size();

	// Create vertex array object
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	// Create vertex buffer
	glGenBuffers(1, &vbuf);
	glBindBuffer(GL_ARRAY_BUFFER, vbuf);
	glBufferData(GL_ARRAY_BUFFER, verts.size() * sizeof(vert), verts.data(), GL_DYNAMIC_DRAW);
	// Specify vertex attributes
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(vert), 0);
	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(vert), (GLvoid*)sizeof(glm::vec2));
	// Create index buffer
	glGenBuffers(1, &ibuf);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibuf);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, ids.size() * sizeof(GLuint), ids.data(), GL_DYNAMIC_DRAW);

	// Cleanup state
	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void initTextures() {
	// Create initial texture data
	// Type & Mass, TEMP?TIME?, DirX, DirY
	initTexData = vector<glm::vec4>(texWidth * texHeight, glm::vec4(1000.0, 0.0, 0.0, 0.0));

	// Create background
	for (int r = 1; r < texHeight - 1; r++) {
		for (int c = 1; c < texWidth - 1; c++) {
			int idx = r * texWidth + c;
			initTexData[idx] = glm::vec4(0.0, 0.0, 0.0, 0.0);
		}
	}

	// int idx = 56 * texWidth + 56;
	// initTexData[idx] = glm::vec4(1.0, 0.0, 0.0, -9.81);

	// Create texture objects
	glGenTextures(1, &prevTexture);
	glBindTexture(GL_TEXTURE_2D, prevTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, texWidth, texHeight, 0, GL_RGBA, GL_FLOAT, initTexData.data());
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


	glGenTextures(1, &currTexture);
	glBindTexture(GL_TEXTURE_2D, currTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, texWidth, texHeight, 0, GL_RGBA, GL_FLOAT, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glBindTexture(GL_TEXTURE_2D, 0);


	// Create framebuffer object (draw to currTexture)
	glGenFramebuffers(1, &fbo);
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, currTexture, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	assert(glGetError() == GL_NO_ERROR);
}

void display() {
	try {
		// Start the Dear ImGui frame
		ImGui_ImplOpenGL3_NewFrame();
		ImGui_ImplGLUT_NewFrame();
		my_display_code();
		ImGuiIO& io = ImGui::GetIO();
		width = io.DisplaySize.x;
		height = io.DisplaySize.y;

		glBindVertexArray(vao);

		// Pass 1: GPGPU output to texture =============================

		glBindFramebuffer(GL_FRAMEBUFFER, fbo);		// Enable render-to-texture
		glViewport(0, 0, texWidth, texHeight);		// Reshape to texture size
		glUseProgram(gpgpuShader);

		glUniform1i(uniClicked, clicked);
		glUniform1i(uniRand, randNumber);
		glUniform1i(uniTime, timeSinceStart);
		glUniform2f(uniClick, click.x, click.y);
		glUniform1f(uniType, type);

		// Do multiple steps before displaying the results
		// for (int i = 0; i < nsteps; i++) {
				
		// Clear the texture
		glClear(GL_COLOR_BUFFER_BIT);
				
		// Use the previous texture output as input
		glActiveTexture(GL_TEXTURE0 + 0);
		glBindTexture(GL_TEXTURE_2D, prevTexture);
		
		// Draw the quad to invoke the shader
		glDrawElements(GL_TRIANGLES, vcount, GL_UNSIGNED_INT, NULL);

		// Swap prev and curr textures
		std::swap(prevTexture, currTexture);
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, currTexture, 0);
		
		// }


		// Pass 2: Display GPGPU output ===============================

		glBindFramebuffer(GL_FRAMEBUFFER, 0);		// Restore default framebuffer (draw to window)
		glViewport(0, 0, width, height);			// Reshape to window size
		glUseProgram(dispShader);


		// Fix aspect ratio
		glm::mat4 xform(1.0f);
		float winAspect = (float)width / (float)height;
		float texAspect = (float)texWidth / (float)texHeight;
		xform[0][0] = glm::min(1.0f, texAspect / winAspect);
		xform[1][1] = glm::min(1.0f, winAspect / texAspect);
		//xform[2][0] = 2.0f;
		// Send transformation matrix to shader
		glUniformMatrix4fv(uniXform, 1, GL_FALSE, value_ptr(xform));

		// Clear the window
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		// Draw the current texture (GPGPU output after swap)
		glActiveTexture(GL_TEXTURE0 + 0);
		glBindTexture(GL_TEXTURE_2D, prevTexture);
		// Draw the quad
		glDrawElements(GL_TRIANGLES, vcount, GL_UNSIGNED_INT, NULL);


		// Revert state
		glBindTexture(GL_TEXTURE_2D, 0);
		glBindVertexArray(0);
		glUseProgram(0);
	
		// Rendering
		ImGui::Render();
	    glViewport(0, 0, (GLsizei)io.DisplaySize.x, (GLsizei)io.DisplaySize.y);
    	glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
    	//glClear(GL_COLOR_BUFFER_BIT);
		ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

		// Display the back buffer
		glutSwapBuffers();

		clicked = 0;
		randNumber = rand();
		timeSinceStart++;

	} catch (const exception& e) {
		cerr << "Fatal error: " << e.what() << endl;
		glutLeaveMainLoop();
	}
}

void reshape(GLint width, GLint height) {
	ImGuiIO& io = ImGui::GetIO();
	::width = width;
	::height = height;
	glViewport(0, 0, (GLsizei)io.DisplaySize.x, (GLsizei)io.DisplaySize.y);
}

void keyRelease(unsigned char key, int x, int y) {
	switch (key) {
	case 27:	// Escape key
		menu(MENU_EXIT);
		break;
	}
}

// Convert a position in screen space into texture space
glm::ivec2 mouseToTexCoord(int x, int y) {
	glm::vec3 mousePos(x, y, 1.0f);

	// Convert screen coordinates into clip space
	glm::mat3 screenToClip(1.0f);
	screenToClip[0][0] = 2.0f / width;
	screenToClip[1][1] = -2.0f / height;	// Flip y coordinate
	screenToClip[2][0] = -1.0f;
	screenToClip[2][1] = 1.0f;

	// Invert the aspect ratio correction (from display())
	float winAspect = (float)width / (float)height;
	float texAspect = (float)texWidth / (float)texHeight;
	glm::mat3 invAspect(1.0f);
	invAspect[0][0] = glm::max(1.0f, winAspect / texAspect);
	invAspect[1][1] = glm::max(1.0f, texAspect / winAspect);

	// Convert to texture coordinates
	glm::mat3 quadToTex(1.0f);
	quadToTex[0][0] = texWidth / 2.0f;
	quadToTex[1][1] = texHeight / 2.0f;
	quadToTex[2][0] = texWidth / 2.0f;
	quadToTex[2][1] = texHeight / 2.0f;

	// Shift Mouse to Texture
	//glm::mat3 shiftToTex(1.0f);
	//shiftToTex[2][0] = 2.0f;

	// Get texture coordinate that was clicked on
	glm::ivec2 texPos = glm::ivec2(glm::floor(/*shiftToTex * */quadToTex * invAspect * screenToClip * mousePos));
	return texPos;
}

void mouseBtn(int button, int state, int x, int y) {
	if (button && state) {
	// 	glBindTexture(GL_TEXTURE_2D, prevTexture);
	// 	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texWidth, texHeight, GL_RGB, GL_UNSIGNED_BYTE, initTexData.data());
	// 	glBindTexture(GL_TEXTURE_2D, 0);
		click = mouseToTexCoord(x, y);
		clicked = 1;
		// glutPostRedisplay();
		// std::cout << "Click: '" << click.x << " " << click.y << "'\n";
		// std::cout << "Clicked: '" << clicked << "'\n";
	}
}

void mouseMove(bool dragging, int x, int y) {
	mouseBtn(dragging, dragging, x, y);
}

void idle() {
	if (updateTimer == 10000)	{ 
		glutPostRedisplay();
		updateTimer = 0;
		//std::cout << "My Pixel: " << initTexData[56 * texWidth + 56].x << " " << initTexData[56 * texWidth + 56].y << " " << initTexData[56 * texWidth + 56].z << " " << initTexData[56 * texWidth + 56].w << "\n";
		//std::cout << "Below Pixel: " << initTexData[56 * texWidth + 55].x << " " << initTexData[56 * texWidth + 55].y << " " << initTexData[56 * texWidth + 55].z << " " << initTexData[56 * texWidth + 55].w << "\n";
	} else {
		updateTimer++;
	}
}

void menu(int cmd) {
	switch (cmd) {
	case MENU_SWITCH:
		type = type_arr[idx++];
		if (idx == 6) idx = 0;
		break;
	case MENU_EXIT:
		glutLeaveMainLoop();
		break;
	}
}

void cleanup() {
	// Release all resources
	if (prevTexture) { glDeleteTextures(1, &prevTexture); prevTexture = 0; }
	if (currTexture) { glDeleteTextures(1, &currTexture); currTexture = 0; }
	if (dispShader) { glDeleteProgram(dispShader); dispShader = 0; }
	if (gpgpuShader) { glDeleteProgram(gpgpuShader); gpgpuShader = 0; }
	uniXform = 0;
	if (vao) { glDeleteVertexArrays(1, &vao); vao = 0; }
	if (vbuf) { glDeleteBuffers(1, &vbuf); vbuf = 0; }
	if (ibuf) { glDeleteBuffers(1, &ibuf); ibuf = 0; }
	vcount = 0;
	if (fbo) { glDeleteFramebuffers(1, &fbo); fbo = 0; }
}

// Helper to display a little (?) mark which shows a tooltip when hovered.
// In your own code you may want to display an actual icon if you are using a merged icon fonts (see docs/FONTS.md)
static void HelpMarker(const char* desc)
{
    ImGui::TextDisabled("(?)");
    if (ImGui::IsItemHovered())
    {
        ImGui::BeginTooltip();
        ImGui::PushTextWrapPos(ImGui::GetFontSize() * 35.0f);
        ImGui::TextUnformatted(desc);
        ImGui::PopTextWrapPos();
        ImGui::EndTooltip();
    }
}

void my_display_code() {
	ImGuiIO& io = ImGui::GetIO();

	//ImGui::ShowDemoWindow();
	ImGui::SetNextWindowPos(ImVec2(0.0, 0.0), ImGuiCond_Once);
	ImGui::SetNextWindowSize(ImVec2(215.0, 135.0), ImGuiCond_Once);

    {
        ImGui::Begin("Click Here to Get Started!");

		const char* elems_names[10] = { "Erase", "Block", "Steam", "Water", "Ice", "Plants", "Dirt", "Stone", "Magma", "Fire" };		
		const char* selection[2] = { "Yes", "No" };

		static int selected = 3;
		for (int n = 0; n < 10; n++)
		{
			char buf[32];
			sprintf(buf, "%s", elems_names[n]);
			if (ImGui::Selectable(buf, selected == n)) {
				selected = n;
				type = type_arr[n];
			}
		}

		if (ImGui::Button("ERASE ALL"))
            ImGui::OpenPopup("my_select_popup");

        if (ImGui::BeginPopup("my_select_popup"))
        {
            ImGui::Text("Are you sure?");
            ImGui::Separator();
            for (int i = 0; i < IM_ARRAYSIZE(selection); i++)
                if (ImGui::Selectable(selection[i]))
                    if (i == 0)
						toClearTexture = true;
            ImGui::EndPopup();
        }
			
		ImGui::End();
    }

	if (!io.WantCaptureMouse) {
        mouseBtn(ImGui::IsMouseClicked(0), ImGui::IsMouseDown(0), io.MousePos.x, io.MousePos.y);
		mouseMove(ImGui::IsMouseDragging(ImGuiMouseButton_Left), io.MousePos.x, io.MousePos.y);
	}

	if (toClearTexture) {
		clear_texture();
		toClearTexture = false;
	}
}

void clear_texture() {
	glBindTexture(GL_TEXTURE_2D, prevTexture);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texWidth, texHeight, GL_RGB, GL_UNSIGNED_BYTE, initTexData.data());
	glBindTexture(GL_TEXTURE_2D, 0);
}