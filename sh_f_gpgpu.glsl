#version 330

smooth in vec2 fragTC;		// Interpolated texture coordinates

// Outside Variables
uniform vec2 click;
uniform float type;
uniform int clicked;
uniform int randNumber;
uniform int timeSinceStart;

uniform sampler2D prevTex;	// Texture sampler

out vec4 outCol;	// Final pixel color

void main() {
	// TODO LIST
	// Add Collision Detection - update velocity if detecting another non-empty pixel
		// at willMove, check if it would move into a block, then change canMove?
		// ex: should move down instead of down-left
		// currently I say a pixel can only move if it wouldn't be in a b_grd square, but for diagonals I'm assuming something else would pick it up, big issue
	// ISSUE, DUPLICATION ON CORNERS :/
	// If water collides with something below it, it gets a random x direction to move :)
	// Try Adding Stone - mass is 3
		// Have Pixels Swap Places Based on Greatest Mass or Force?
	// Try Adding Magma
		// If Stone is Next to Magma, It Becomes Magma
	// Try Adding Steam
		// If Water is Next to Magma, It Becomes Steam

	// GUI STUFF
		// Dear IMGUI

	// Get pixel location of this fragment
	ivec2 texelCoord = ivec2(fragTC * textureSize(prevTex, 0));

	// Get current pixel
	vec4 c = texelFetch(prevTex, texelCoord, 0);

	// Definitions
	float B_GRD = 0.0;
	float BLOCK = 1000.0;
	float FIRE = 0.3;
	float STEAM = 0.5;
	float WATER = 1.0;
	float PLANT = 1.25;
	float ICE = 1.5;
	float DIRT = 1.75;
	float MAGMA = 2.0;
	float STONE = 3.0;
	int fire_life = 100;
	int ice_life = 500;
	vec2 GRAV = vec2(0, -9.81);
	vec4 ERASE = vec4(0, 0, 0, 0);

	// Update Current to Correct Color
	if (type == B_GRD && (click.x == texelCoord.x && click.y == texelCoord.y && clicked == 1 || click.x - 1 == texelCoord.x && click.y == texelCoord.y && clicked == 1 ||
		click.x - 1 == texelCoord.x && click.y - 1 == texelCoord.y && clicked == 1 || click.x == texelCoord.x && click.y - 1 == texelCoord.y && clicked == 1 ||
		click.x + 1 == texelCoord.x && click.y - 1 == texelCoord.y && clicked == 1 || click.x + 1 == texelCoord.x && click.y == texelCoord.y && clicked == 1 ||
		click.x + 1 == texelCoord.x && click.y + 1 == texelCoord.y && clicked == 1 || click.x == texelCoord.x && click.y + 1 == texelCoord.y && clicked == 1 ||
		click.x - 1 == texelCoord.x && click.y + 1 == texelCoord.y && clicked == 1)) {
			outCol = ERASE;
	} else if (click.x == texelCoord.x && click.y == texelCoord.y && clicked == 1) {
		if (type == BLOCK) {
			outCol = vec4(type, timeSinceStart, 0.0, 0.0);
		} else if (type == STEAM) {
			outCol = vec4(type, timeSinceStart, 0.0, -1 * GRAV.y);
		} else if (type == WATER) {
			outCol = vec4(type, timeSinceStart, 0.0, GRAV.y);
		} else if (type == MAGMA) {
			outCol = vec4(type, timeSinceStart, 0.0, GRAV.y);
		} else if (type == STONE) {
			outCol = vec4(type, timeSinceStart, 0.0, GRAV.y);
		} else if (type == FIRE) {
			outCol = vec4(type, fire_life, 0.0, -1 * GRAV.y);
		} else if (type == DIRT) {
			outCol = vec4(type, timeSinceStart, 0.0, GRAV.y);
		} else if (type == ICE) {
			outCol = vec4(type, ice_life, 0.0, GRAV.y);
		} else if (type == PLANT) {
			outCol = vec4(type, timeSinceStart, 0.0, GRAV.y);
		}
	} else if (c.x == BLOCK) {
		// Check if BLOCK
		outCol = c;
	} else {
		// Get the statuses of the surrounding pixels (3x3 Grid)
		vec4 t  = texelFetch(prevTex, texelCoord + ivec2( 0,  1), 0);
		vec4 b  = texelFetch(prevTex, texelCoord + ivec2( 0, -1), 0);
		vec4 l  = texelFetch(prevTex, texelCoord + ivec2(-1,  0), 0);
		vec4 r  = texelFetch(prevTex, texelCoord + ivec2( 1,  0), 0);
		
		vec4 tl = texelFetch(prevTex, texelCoord + ivec2(-1,  1), 0);
		vec4 tr = texelFetch(prevTex, texelCoord + ivec2( 1,  1), 0);
		vec4 bl = texelFetch(prevTex, texelCoord + ivec2(-1, -1), 0);
		vec4 br = texelFetch(prevTex, texelCoord + ivec2( 1, -1), 0);

		// The rest of the surrounding pixels - ugh
		vec4 ttll	= texelFetch(prevTex, texelCoord + ivec2(-2,  2), 0);
		vec4 ttl	= texelFetch(prevTex, texelCoord + ivec2(-1,  2), 0);
		vec4 tt		= texelFetch(prevTex, texelCoord + ivec2( 0,  2), 0);
		vec4 ttr	= texelFetch(prevTex, texelCoord + ivec2( 1,  2), 0);
		vec4 ttrr	= texelFetch(prevTex, texelCoord + ivec2( 2,  2), 0);
		
		vec4 tll	= texelFetch(prevTex, texelCoord + ivec2(-2,  1), 0);
		vec4 trr	= texelFetch(prevTex, texelCoord + ivec2( 2,  1), 0);
		vec4 ll		= texelFetch(prevTex, texelCoord + ivec2(-2,  0), 0);
		vec4 rr		= texelFetch(prevTex, texelCoord + ivec2( 2,  0), 0);
		vec4 bll	= texelFetch(prevTex, texelCoord + ivec2(-2, -1), 0);
		vec4 brr	= texelFetch(prevTex, texelCoord + ivec2( 2, -1), 0);
		
		vec4 bbll	= texelFetch(prevTex, texelCoord + ivec2(-2, -2), 0);
		vec4 bbl	= texelFetch(prevTex, texelCoord + ivec2(-1, -2), 0);
		vec4 bb		= texelFetch(prevTex, texelCoord + ivec2( 0, -2), 0);
		vec4 bbr	= texelFetch(prevTex, texelCoord + ivec2( 1, -2), 0);
		vec4 bbrr	= texelFetch(prevTex, texelCoord + ivec2( 2, -2), 0);

		// Check if current pixel should move
			// Check current direction
				// If nothing in way, it should be sucked up by another pixel
		// If current pixel will move, update with a surrounding pixel
			// If current pixel is empty or it will move, check for update
				// Update with greatest force that will move into pixel

		// What if 2 pixels think they can move to same square?

		// Get Current Pixel Velocities
		float vcx = c.z;
		float vcy = c.w;
		int canMove = 0;	// t - 1, tl - 2, l - 3, bl - 4, b - 5, br - 6, r - 7, tr - 8, empty - 9
		int hitDir = -1;

		// Check if Pixel can Move Left
		if (vcx < 0) {
			// Down and Left
			if (vcy < 0) {
				if (bl.x == B_GRD) {
					canMove = 4;
				} else if (b.x == B_GRD && (abs(vcy) >= abs(vcx) || l.x != B_GRD)) {
					// If something is on left, can still move down
					canMove = 5;
				} else if (l.x == B_GRD && (abs(vcx) >= abs(vcy) || b.x != B_GRD)) {
					// If something is below, can still move left
					canMove = 3;
				} else {
					hitDir = 4;
				}
			// Up and Left
			} else if (vcy > 0) {
				if (tl.x == B_GRD) {
					canMove = 2;
				} else if (t.x == B_GRD && (abs(vcy) >= abs(vcx) || l.x != B_GRD)) {
					// If something is on left, can still move up
					canMove = 1;
				} else if (l.x == B_GRD && (abs(vcx) >= abs(vcy) || t.x != B_GRD)) {
					// If something is above, can still move left
					canMove = 3;
				} else {
					hitDir = 2;
				}
			// Just Left
			} else {
				if (l.x == B_GRD) {
					canMove = 3;
				} else {
					hitDir = 3;
				}
			}
		// Check if Pixel can move right
		} else if (vcx > 0) {
			// Up and Right
			if (vcy > 0) {
				if (tr.x == B_GRD) {
					canMove = 8;
				} else if (t.x == B_GRD && (abs(vcy) >= abs(vcx) || r.x != B_GRD)) {
					// If something is on right, can still move up
					canMove = 1;
				} else if (r.x == B_GRD && (abs(vcx) >= abs(vcy) || t.x != B_GRD)) {
					// If something is above, can still move right
					canMove = 7;
				} else {
					hitDir = 8;
				}
			// Down and Right
			} else if (vcy < 0) {
				if (br.x == B_GRD) {
					canMove = 6;
				} else if (b.x == B_GRD && (abs(vcy) >= abs(vcx) || r.x != B_GRD)) {
					// If something is on right, can still move down
					canMove = 5;
				} else if (r.x == B_GRD && (abs(vcx) >= abs(vcy) || b.x != B_GRD)) {
					// If something is below, can still move right
					canMove = 7;
				} else {
					hitDir = 6;
				}
			// Just Right
			} else {
				if (r.x == B_GRD) {
					canMove = 7;
				} else {
					hitDir = 7;
				}
			}
		// Check if pixel moves vertically
		} else {
			// Just Down
			if (vcy < 0) {
				if (b.x == B_GRD) {
					canMove = 5;
				} else {
					hitDir = 5;
				}
			// Just Up
			} else if (vcy > 0) {
				if (t.x == B_GRD) {
					canMove = 1;
				} else {
					hitDir = 1;
				}
			} else {
				hitDir = 0;
			}
		}

		// Empty pixels can move
		if (c.x == B_GRD) {
			canMove = 9;
			hitDir = 9;
		}

		// The forces of ALL the pixels
		float ft	=  abs(dot(vec2(t.z, t.w), t.x * GRAV));
		float fb	=  abs(dot(vec2(b.z, b.w), b.x * GRAV));
		float fl	=  abs(dot(vec2(l.z, l.w), l.x * GRAV));
		float fr	=  abs(dot(vec2(r.z, r.w), r.x * GRAV));

		float ftl	= abs(dot(vec2(tl.z, tl.w), tl.x * GRAV));
		float ftr	= abs(dot(vec2(tr.z, tr.w), tr.x * GRAV));
		float fbl	= abs(dot(vec2(bl.z, bl.w), bl.x * GRAV));
		float fbr	= abs(dot(vec2(br.z, br.w), br.x * GRAV));

		float fttll = abs(dot(vec2(ttll.z, ttll.w), ttll.x * GRAV));
		float fttl	= abs(dot(vec2(ttl.z, ttl.w), ttl.x * GRAV));
		float ftt	= abs(dot(vec2(tt.z, tt.w), tt.x * GRAV));
		float fttr	= abs(dot(vec2(ttr.z, ttr.w), ttr.x * GRAV));
		float fttrr = abs(dot(vec2(ttrr.z, ttrr.w), ttrr.x * GRAV));
		
		float ftll	= abs(dot(vec2(tll.z, tll.w), tll.x * GRAV));
		float ftrr	= abs(dot(vec2(trr.z, trr.w), trr.x * GRAV));
		float fll	= abs(dot(vec2(ll.z, ll.w), ll.x * GRAV));
		float frr	= abs(dot(vec2(rr.z, rr.w), rr.x * GRAV));
		float fbll	= abs(dot(vec2(bll.z, bll.w), bll.x * GRAV));
		float fbrr	= abs(dot(vec2(brr.z, brr.w), brr.x * GRAV));
		
		float fbbll = abs(dot(vec2(bbll.z, bbll.w), bbll.x * GRAV));
		float fbbl	= abs(dot(vec2(bbl.z, bbl.w), bbl.x * GRAV)); 
		float fbb	= abs(dot(vec2(bb.z, bb.w), bb.x * GRAV));
		float fbbr	= abs(dot(vec2(bbr.z, bbr.w), bbr.x * GRAV));
		float fbbrr = abs(dot(vec2(bbrr.z, bbrr.w), bbrr.x * GRAV));

		float curForce = abs(dot(vec2(c.z, c.w), c.x * GRAV));

		int willMove = 0;	// t - 1, tl - 2, l - 3, bl - 4, b - 5, br - 6, r - 7, tr - 8, empty - 9

		// Check if something else will take pixel location instead of me
		// AKA check if something surrounding the pixel I want to move to has a greater force than 
		// TODO - CHECK IF PIXEL WILL MOVE INTO THE PIXEL I WANT (DIR CHECK FOR EACH), then check the new pixel it would move into (pretty sure it applies to diagonals only)
		if (canMove == 1) {	// Top
			if ((fl >= curForce && l.z > 0 && l.w > 0) || (ftl >= curForce && tl.z > 0 && tl.w == 0) || (fttl >= curForce && ttl.z > 0 && ttl.w < 0) || 
					(ftt >= curForce && tt.z == 0 && tt.w < 0) || (fttr >= curForce && ttr.z < 0 && ttr.w < 0) || (ftr >= curForce && tr.z < 0 && tr.w == 0) || 
						(fr >= curForce && r.z < 0 && r.w > 0)) {
				hitDir = 1;
			} else {
				willMove = 1;
			}
		} else if (canMove == 2) {	// Top Left
			if ((fl >= curForce && l.z == 0 && l.w > 0) || (fll >= curForce && ll.z > 0 && ll.w > 0) || (ftll >= curForce && tll.z > 0 && tll.w == 0) || 
					(fttll >= curForce && ttll.z > 0 && ttll.w < 0) || (fttl >= curForce && ttl.z == 0 && ttl.w < 0) || (ftt >= curForce && tt.z < 0 && tt.w < 0) || 
						(ft >= curForce && t.z < 0 && t.w == 0)) {
				hitDir = 2;
			} else {
				if (tl.x != B_GRD) {
					// Block in way, check if can move up or left instead
					if (tll.x == B_GRD) {
						willMove = 3;
					} else if (ttl.x == B_GRD) {
						// Can move up but not down
						willMove = 1;
					}
				} else {
					willMove = 2;
				}
			}
		} else if (canMove == 3) {	// Left
			if ((fb >= curForce && b.z < 0 && b.w > 0) || (fbl >= curForce && bl.z == 0 && bl.w > 0) || (fbll >= curForce && bll.z > 0 && bll.w > 0) || 
					(fll >= curForce && ll.z > 0 && ll.w == 0) || (ftll >= curForce && tll.z > 0 && tll.w < 0) || (ftl >= curForce && tl.z == 0 && tl.w < 0) || 
						(ft >= curForce && t.z < 0 && t.w < 0)) {
				hitDir = 3;
			} else {
				willMove = 3;
			}
		} else if (canMove == 4) {	// Bottom Left
			if ((fb >= curForce && b.z < 0 && b.w == 0) || (fbb >= curForce && bb.z < 0 && bb.w > 0) || (fbbl >= curForce && bbl.z == 0 && bbl.w > 0) || 
					(fbbll >= curForce && bbll.z > 0 && bbll.w > 0) || (fbll >= curForce && bll.z > 0 && bll.w == 0) || (fll >= curForce && ll.z > 0 && ll.w < 0) || 
						(fl >= curForce && l.z == 0 && ll.w < 0)) {
				hitDir = 4;
			} else {
				if (bl.x != B_GRD) {
					// Block in way, check if can move down or left instead
					if (bll.x == B_GRD) {
						// Can move left but not down
						willMove = 3;
					} else if (bbl.x == B_GRD) {
						// Can move down but not left
						willMove = 5;
					}
				} else {
					willMove = 4;
				}
			}
		} else if (canMove == 5) {	// Bottom
			if ((fr >= curForce && r.z < 0 && r.w < 0) || (fbr >= curForce && br.z < 0 && br.w == 0) || (fbbr >= curForce && bbr.z < 0 && bbr.w > 0) || 
					(fbb >= curForce && bb.z == 0 && bb.w > 0) || (fbbl >= curForce && bbl.z > 0 && bbl.w > 0) || (fbl >= curForce && bl.z > 0 && bl.w == 0) || 
						(fl >= curForce && l.z > 0 && l.w < 0)) {
				hitDir = 5;
			} else {
				willMove = 5;
			}
		} else if (canMove == 6) {	// Bottom Right
			if ((fr >= curForce && r.z == 0 && r.w < 0) || (frr >= curForce && rr.z < 0 && rr.w < 0) || (fbrr >= curForce && brr.z < 0 && brr.w == 0) || 
					(fbbrr >= curForce && bbrr.z < 0 && bbrr.w > 0) || (fbbr >= curForce && bbr.z == 0 && bbr.w > 0) || (fbb >= curForce && bb.z > 0 && bb.w > 0) || 
						(fb >= curForce && b.z > 0 && b.w == 0)) {
				hitDir = 6;
			} else {
				if (br.x != B_GRD) {
					// Block in way, check if can move down or right instead
					if (brr.x == B_GRD) {
						// Can move right
						willMove = 7;
					} else if (bbr.x == B_GRD) {
						// Can move down
						willMove = 5;
					}
				} else {
					willMove = 6;
				}
			}
		} else if (canMove == 7) {	// Right
			if ((ft >= curForce && t.z > 0 && t.w < 0) || (ftr >= curForce && tr.z == 0 && tr.w < 0) || (ftrr >= curForce && trr.z < 0 && trr.w < 0) ||
					(frr >= curForce && rr.z < 0 && rr.w == 0) || (fbrr >= curForce && brr.z < 0 && brr.w > 0) || (fbr >= curForce && br.z == 0 && br.w > 0) || 
						(fb >= curForce && b.z > 0 && b.w > 0)) {
				hitDir = 7;
			} else {
				willMove = 7;
			}
		} else if (canMove == 8) {	// Top Right
			if ((ft >= curForce && t.z > 0 && t.w == 0) || (ftt >= curForce && tt.z > 0 && tt.w < 0) || (fttr >= curForce && ttr.z == 0 && ttr.w < 0) ||
					(fttrr >= curForce && ttrr.z < 0 && ttrr.w < 0) || (ftrr >= curForce && trr.z < 0 && trr.w == 0) || (frr >= curForce && rr.z < 0 && trr.w > 0) || 
						(fr >= curForce && r.z == 0 && r.w > 0)) {
				hitDir = 8;
			} else {
				if (tr.x != B_GRD) {
					// Block in way, check if can move up or right instead
					if (trr.x == B_GRD) {
						willMove = 7;
					} else if (ttr.x == B_GRD) {
						willMove = 1;
					}
				} else {
					willMove = 8;
				}
			}
		} else if (canMove == 9) {	// Empty
			willMove = 9;
		} else {
			hitDir = 0;
		}

		// For each location
			// Get forces of new surrounding pixels
			// Find max force
			// If current pixel is the max force
				// Pixel will move, so update current pixel to pixel of old surrounding pixel that had max force
			// If current pixel is not max force
				// Pixel will not move, so current pixel stays the same

		// At this point I am assuming my current pixel will move to a new pixel, so I need to update my pixel
		// WRONG, LET MY PIXEL MOVE, THEN NEXT ITERATION UPDATE MY PIXEL
		if (willMove != 0 && c.x == B_GRD) {
			// Check if any surrounding pixel will move into current pixel
			c = ERASE;
			curForce = 0;

			// TODO: How do I check which pixel should move into my pixel?
				// I can check the movement of all surrounding pixels
					// Then check if it would collide
						// Then check which should move into me
					// AKA a surrounding pixel would move into a block pixel on the left of me, which then means it should moves into me
						// Issue if we assume a pixel should move into me, but I choose a different pixel ...?

			// Getting the directions of surrounding pixels
			vec2 t_dir = vec2(t.z, t.w);
			vec2 tl_dir = vec2(tl.z, tl.w);
			vec2 l_dir = vec2(l.z, l.w);
			vec2 bl_dir = vec2(bl.z, bl.w);
			vec2 b_dir = vec2(b.z, b.w);
			vec2 br_dir = vec2(br.z, br.w);
			vec2 r_dir = vec2(r.z, r.w);
			vec2 tr_dir = vec2(tr.z, tr.w);

			// Check surrounding pixels for direction to move & mark which move into me
			int t_willMove = 0;
			int tl_willMove = 0;
			int l_willMove = 0;
			int bl_willMove = 0;
			int b_willMove = 0;
			int br_willMove = 0;
			int r_willMove = 0;
			int tr_willMove = 0;

			// Top Direction Check (will it move down (or move down left/right and collide then move down))
			if (t_dir.y < 0) {
				if (t_dir.x > 0) {
					// Down and Right
					if (r.x != B_GRD) {
						t_willMove = 1;
					}
				} else if (t_dir.x < 0) {
					// Down and left
					if (l.x != B_GRD) {
						t_willMove = 1;
					}
				} else {
					t_willMove = 1;
				}
			}

			// Top Left Direction (will it move down right)
			if (tl_dir.y < 0 && tl_dir.x > 0) {
				tl_willMove = 1;
			}

			// Left Direction (will it move right (or move right up/down and collide))
			if (l_dir.x > 0) {
				if (l_dir.y < 0) {
					// Right and Down
					if (b.x != B_GRD) {
						l_willMove = 1;
					}
				} else if (l_dir.y > 0) {
					// Right and Up
					if (t.x != B_GRD) {
						l_willMove = 1;
					}
				} else {
					// Right
					l_willMove = 1;
				}
			}

			// Bottom Left Direction (will it move up and right)
			if (bl_dir.y > 0 && bl_dir.x > 0) {
				bl_willMove = 1;
			}

			// Bottom Direction
			if (b_dir.y > 0) {
				if (b_dir.x > 0) {
					// Up and Right
					if (r.x != B_GRD) {
						b_willMove = 1;
					}
				} else if (b_dir.x < 0) {
					// Up and left
					if (l.x != B_GRD) {
						b_willMove = 1;
					}
				} else {
					b_willMove = 1;
				}
			}

			// Bottom Right
			if (br_dir.y > 0 && br_dir.x < 0) {
				br_willMove = 1;
			}

			// Right
			if (r_dir.x < 0) {
				if (r_dir.y < 0) {
					// Left and Down
					if (b.x != B_GRD) {
						r_willMove = 1;
					}
				} else if (r_dir.y > 0) {
					// Right and Up
					if (t.x != B_GRD) {
						r_willMove = 1;
					}
				} else {
					// Right
					r_willMove = 1;
				}
			}

			// Top Right
			if (tr_dir.y < 0 && tr_dir.x < 0) {
				tr_willMove = 1;
			}

			// Check which has highest force and move it :)
			if (t_willMove != 0 && ft > curForce) {	// Top (moving down)
				if (abs(t.w) > abs(t.z)) {
					curForce = ft;
					c = t;
				} else if (t.z > 0 && r.x != B_GRD) {
					curForce = fb;
					c = t;
				} else if (t.z < 0 && l.x != B_GRD) {
					curForce = fb;
					c = t;
				}
			}
			if (tl_willMove != 0 && ftl > curForce) {	// Top Left (moving down right)
				curForce = ftl;
				c = tl;
			}
			if (l_willMove != 0 && fl > curForce) {	// Left (moving right)
				if (abs(l.z) > abs(l.w)) {
					curForce = fl;
					c = l;
				} else if (l.w > 0 && (t.x != B_GRD || tl.x != B_GRD)) {
					curForce = fl;
					c = l;
				} else if (l.w < 0 && (b.x != B_GRD || bl.x != B_GRD)) {
					curForce = fl;
					c = l;
				}
			}
			if (bl_willMove != 0 && fbl > curForce) {	// Bottom Left (moving up right)
				curForce = fbl;
				c = bl;
			}
			if (b_willMove != 0 && fb > curForce) {	// Bottom (moving up)
				if (abs(b.w) > abs(b.z)) {
					curForce = fb;
					c = b;
				} else if (b.z > 0 && r.x != B_GRD) {
					curForce = fb;
					c = b;
				} else if (b.z < 0 && l.x != B_GRD) {
					curForce = fb;
					c = b;
				}
			}
			if (br_willMove != 0 && fbr > curForce) {	// Bottom Right (moving up left)
				curForce = fbr;
				c = br;
			}
			if (r_willMove != 0 && fr > curForce) {	// Right (moving left)
				if (abs(r.z) > abs(r.w)) {
					curForce = fr;
					c = r;
				} else if (r.w > 0 && (t.x != B_GRD || tr.x != B_GRD)) {
					curForce = fr;
					c = r;
				} else if (r.w < 0 && (b.x != B_GRD || br.x != B_GRD)) {
					curForce = fr;
					c = r;
				}
			}
			if (tr_willMove != 0 && ftr > curForce) {	// Top Right (moving down left)
				curForce = ftr;
				c = tr;
			}
		} else {
			if (hitDir != -1) {
				// This means my pixel is not moving during this iteration, so let's update with some values
				// DO COLLISION STUFF HERE - TIS A BIT WEIRD ATM :/
				// t - 1, tl - 2, l - 3, bl - 4, b - 5, br - 6, r - 7, tr - 8, empty - 9 : Directions to move
				if (c.x == STEAM) {
					if (t.x != MAGMA && t.x != B_GRD) {
						c.x = WATER;
						c.y = timeSinceStart;
						c.w = GRAV.y;
					} else if (t.x == WATER) {
						c.x = WATER;
						c.y = t.y;
						c.z = t.z;
						c.w = t.w;
					}
				} else if (c.x == WATER) {
					if (t.x == STONE) {
						c.x = STONE;
						c.y = t.y;
						c.z = t.z;
						c.w = t.w;
					} else if (t.x == MAGMA) {
						c.x = STONE;
						c.y = t.y;
						c.z = t.z;
						c.w = t.w;
					} else if (l.x == MAGMA) {
						c.x = STEAM;
						c.y = timeSinceStart;
						c.w = -1.0 * GRAV.y;
					} else if (r.x == MAGMA) {
						c.x = STEAM;
						c.y = timeSinceStart;
						c.w = -1.0 * GRAV.y;
					} else if (b.x == STEAM) {
						c.x = STEAM;
						c.y = timeSinceStart;
						c.w = -1.0 * GRAV.y;
					} else if (b.x == ICE) {
						c.x = b.x;
						c.y = b.y;
						c.z = b.z;
						c.w = b.w;
					} else if (t.x == DIRT) {
						c.x = t.x;
						c.y = t.y;
						c.z = t.z;
						c.w = t.w;
					}
				} else if (c.x == MAGMA) {
					if (timeSinceStart - c.y > 200) {
						c.x = STONE;
						c.y = timeSinceStart;
					} else if (b.x == WATER) {
						c.x = STEAM;
						c.y = timeSinceStart;
						c.w = -1.0 * GRAV.y;
					} else if (l.x == WATER) {
						c.x = STONE;
						c.y = timeSinceStart;
					} else if (r.x == WATER) {
						c.x = STONE;
						c.y = timeSinceStart;
					}
				} else if (c.x == STONE) {
					if (t.x == MAGMA && timeSinceStart - (t.y - c.y) > 10) {
						c.x = MAGMA;
						c.y = timeSinceStart;
					} else if (b.x == MAGMA && timeSinceStart - (t.y - c.y) > 10) {
						c.x = MAGMA;
						c.y = timeSinceStart;
					} else if (l.x == MAGMA && timeSinceStart - (t.y - c.y) > 10) {
						c.x = MAGMA;
						c.y = timeSinceStart;
					} else if (r.x == MAGMA && timeSinceStart - (t.y - c.y) > 10) {
						c.x = MAGMA;
						c.y = timeSinceStart;
					} else if (b.x == WATER) {
						c.x = WATER;
						c.y = b.y;
						c.z = b.z;
						c.w = b.w;
					}
				} else if (c.x == ICE) {
					c.y -= 1.0;
					if (c.y == 0) {
						c.x = WATER;
					} else if (t.x == WATER) {
						c.x = t.x;
						c.y = t.y;
						c.z = t.z;
						c.w = t.w;
					}
				} else if (c.x == DIRT) {
					if (b.x == WATER) {
						c.x = b.x;
						c.y = b.y;
						c.z = b.z;
						c.w = b.w;
					}
				}
			} else {
				c = ERASE;
			}
		}
		// Update Current Pixel Velocities
		// TODO: Update Dir Here
		if (c.x == WATER) {
			if (randNumber % 2 == 0) {
				c.z += 0.5;
				if (int(c.z) > 1) {
					c.z = 0.0;
				}
			} else {
				c.z -= 0.5;
				if (int(c.z) < -1) {
					c.z = 0.0;
				}
			}
		} else if (c.x == STEAM) {
			if (randNumber % 2 == 0) {
				c.z += 0.5;
				if (int(c.z) > 1) {
					c.z = 0.0;
				}
			} else {
				c.z -= 0.5;
				if (int(c.z) < -1) {
					c.z = 0.0;
				}
			}
		} else if (c.x == MAGMA) {
			if (c.z != 0.0) {
				c.z = 0.0;
			} else if (b.x != B_GRD) {
				if (randNumber % 2 > 0) {
					c.z += 1.0;
				} else {
					c.z -= 1.0;
				}
			}
		} else if (c.x == STONE) {
			if (c.z != 0.0) {
				c.z = 0.0;
			}
		} else if (c.x == FIRE) {
			if (randNumber % 2 == 0) {
				c.z += 0.5;
				if (int(c.z) > 1) {
					c.z = 0.0;
				}
			} else {
				c.z -= 0.5;
				if (int(c.z) < -1) {
					c.z = 0.0;
				}
			}
			c.y -= 1.0;
			if (c.y == 0) {
				c = ERASE;
			}
		} else if (c.x == ICE) {
			if (c.z != 0.0) {
				c.z = 0.0;
			} else if (b.x != B_GRD) {
				if (randNumber % 2 > 0) {
					c.z += 1.0;
				} else {
					c.z -= 1.0;
				}
			}
		}

		outCol = c;
	}
}
