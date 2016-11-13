//
//  Cube.cpp
//  Tutorial06
//
//  Created by aa64mac on 13/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#include<cstring>
#include "Cube.h"

void Cube::SetVertexFlags(unsigned char flags)
{
}

int Cube::GetVertexSize() const
{
    return 6;
}

int Cube::GetVertexCount() const
{
    return 8;
}

int Cube::GetLineIndexCount() const
{
    return 72;
}

int Cube::GetTriangleIndexCount() const
{
    return 36;
}

void Cube::GenerateVertices(float * vertices) const
{
    if (!vertices) {
        return;
    }
    
    const GLfloat verticesData[] = {
        -1.5f, -1.5f, 1.5f, -0.577350, -0.577350, 0.577350,
        -1.5f, 1.5f, 1.5f, -0.577350, 0.577350, 0.577350,
        1.5f, 1.5f, 1.5f, 0.577350, 0.577350, 0.577350,
        1.5f, -1.5f, 1.5f, 0.577350, -0.577350, 0.577350,
        
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350,
        1.5f, 1.5f, -1.5f, 0.577350, 0.577350, -0.577350,
        -1.5f, 1.5f, -1.5f, -0.577350, 0.577350, -0.577350,
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350
    };
    memcpy(vertices, verticesData, sizeof(verticesData));
}

void Cube::GenerateLineIndices(unsigned short * indices) const
{
    if (!indices) {
        return;
    }
    
    const GLushort lineIndices[] = {
        // Front face
        3, 2,  2, 1,  1, 3,   3, 1, 1, 0, 0, 3,
        
        // Back face
        7, 5,  5, 4,  4, 7,   7, 6, 6, 5, 5, 7,
        
        // Left face
        0, 1,  1, 7,  7, 0,   7, 1, 1, 6, 6, 7,
        
        // Right face
        3, 4,  4, 5,  5, 3,   3, 5, 5, 2, 2, 3,
        
        // Up face
        1, 2,  2, 5,  5, 1,   1, 5, 5, 6, 6, 1,
        
        // Down face
        0, 7,  7, 3,  3, 0,   3, 7, 7, 4, 4, 3
    };
    
    memcpy(indices, lineIndices, sizeof(lineIndices));
}

void Cube::GenerateTriangleIndices(unsigned short * indices) const
{
    if (!indices) {
        return;
    }
    
    const GLushort indicesData[] = {
        // Front face
        3, 2, 1, 3, 1, 0,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 7, 7, 1, 6,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 3, 3, 7, 4
    };
    
    memcpy(indices, indicesData, sizeof(indicesData));
}

