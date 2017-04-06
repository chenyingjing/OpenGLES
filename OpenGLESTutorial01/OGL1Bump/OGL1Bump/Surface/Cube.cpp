//
//  Cube.cpp
//  Tutorial06
//
//  Created by aa64mac on 13/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#include<cstring>
#include "Cube.h"

const GLushort indicesData[] = {
    // Front face
    0, 3, 1, 3, 2, 1,
    
    // Back face
    7, 5, 4, 7, 6, 5,
    
    // Left face
    11, 10, 8, 8, 10, 9,
    
    // Right face
    12, 15, 13, 15, 14, 13,
    
    // Up face
    16, 18, 17, 16, 19, 18,
    
    // Down face
    20, 23, 22, 20, 22, 21
};

void Cube::SetVertexFlags(unsigned char flags)
{
    m_vertexFlags = flags;
}

int Cube::GetVertexSize() const
{
    int floatsPerVertex = 3;
    if (m_vertexFlags & VertexFlagsNormals)
        floatsPerVertex += 3;
    if (m_vertexFlags & VertexFlagsTexCoords)
        floatsPerVertex += (2+3);
    
    return floatsPerVertex;
}

int Cube::GetVertexCount()
{
    return 24;
}

int Cube::GetLineIndexCount() const
{
    return 36;
}

int Cube::GetTriangleIndexCount()
{
    return 36;
}

void Cube::GenerateVertices(float * vertices) const
{
    if (!vertices) {
        return;
    }
    
    const GLfloat verticesData[] = {
        -1.5f, -1.5f, 1.5f,
        -1.5f, 1.5f, 1.5f,
        1.5f, 1.5f, 1.5f,
        1.5f, -1.5f, 1.5f,
        
        1.5f, -1.5f, -1.5f,
        1.5f, 1.5f, -1.5f,
        -1.5f, 1.5f, -1.5f,
        -1.5f, -1.5f, -1.5f
    };
    
    const GLfloat verticesDataWithNormal[] = {
        -1.5f, -1.5f, 1.5f, -0.577350, -0.577350, 0.577350,
        -1.5f, 1.5f, 1.5f, -0.577350, 0.577350, 0.577350,
        1.5f, 1.5f, 1.5f, 0.577350, 0.577350, 0.577350,
        1.5f, -1.5f, 1.5f, 0.577350, -0.577350, 0.577350,
        
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350,
        1.5f, 1.5f, -1.5f, 0.577350, 0.577350, -0.577350,
        -1.5f, 1.5f, -1.5f, -0.577350, 0.577350, -0.577350,
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350
    };
    
    GLfloat size = 1.5;
    
//    const GLfloat verticesDataWithNormalAndTexCoords[] = {
//        -size, -size, size, 0, 0, 1, 0, 1,
//        -size, size, size, 0, 0, 1, 0, 0,
//        size, size, size, 0, 0, 1, 1, 0,
//        size, -size, size, 0, 0, 1, 1, 1,
//        
//        size, -size, -size, 0.577350, -0.577350, -0.577350, 0, 1,
//        size, size, -size, 0.577350, 0.577350, -0.577350, 0, 0,
//        -size, size, -size, -0.577350, 0.577350, -0.577350, 1, 0,
//        -size, -size, -size, -0.577350, -0.577350, -0.577350, 1, 1,
//        
//        -size, -size, -size, -0.577350, -0.577350, -0.577350, 0, 1,
//        -size, size, -size, -0.577350, 0.577350, -0.577350, 0, 0,
//        -size, size, size, -0.577350, 0.577350, 0.577350, 1, 0,
//        -size, -size, size, -0.577350, -0.577350, 0.577350, 1, 1,
//        
//        size, -size, size, 0.577350, -0.577350, 0.577350, 0, 1,
//        size, size, size, 0.577350, 0.577350, 0.577350, 0, 0,
//        size, size, -size, 0.577350, 0.577350, -0.577350, 1, 0,
//        size, -size, -size, 0.577350, -0.577350, -0.577350, 1, 1,
//        
//        -size, size, size, 0, 1, 0, 0, 2,
//        -size, size, -size, 0, 1, 0, 0, 0,
//        size, size, -size, 0, 1, 0, 2, 0,
//        size, size, size, 0, 1, 0, 2, 2,
//        
//        -size, -size, -size, -0.577350, -0.577350, -0.577350, 0, 1,
//        -size, -size, size, -0.577350, -0.577350, 0.577350, 0, 0,
//        size, -size, size, 0.577350, -0.577350, 0.577350, 1, 0,
//        size, -size, -size, 0.577350, -0.577350, -0.577350, 1, 1
//    };
    
    GLfloat verticesDataWithNormalAndTexCoords[] = {
        -size, -size, size, 0, 0, 1, 0, 1,  0, 0, 0,
        -size, size, size, 0, 0, 1, 0, 0,  0, 0, 0,
        size, size, size, 0, 0, 1, 1, 0,  0, 0, 0,
        size, -size, size, 0, 0, 1, 1, 1,  0, 0, 0,
        
        size, -size, -size, 0.577350, -0.577350, -0.577350, 0, 1,  0, 0, 0,
        size, size, -size, 0.577350, 0.577350, -0.577350, 0, 0,  0, 0, 0,
        -size, size, -size, -0.577350, 0.577350, -0.577350, 1, 0,  0, 0, 0,
        -size, -size, -size, -0.577350, -0.577350, -0.577350, 1, 1,  0, 0, 0,
        
        -size, -size, -size, -0.577350, -0.577350, -0.577350, 0, 1,  0, 0, 0,
        -size, size, -size, -0.577350, 0.577350, -0.577350, 0, 0,  0, 0, 0,
        -size, size, size, -0.577350, 0.577350, 0.577350, 1, 0,  0, 0, 0,
        -size, -size, size, -0.577350, -0.577350, 0.577350, 1, 1,  0, 0, 0,
        
        size, -size, size, 0.577350, -0.577350, 0.577350, 0, 1,  0, 0, 0,
        size, size, size, 0.577350, 0.577350, 0.577350, 0, 0,  0, 0, 0,
        size, size, -size, 0.577350, 0.577350, -0.577350, 1, 0, 0, 0, 0,
        size, -size, -size, 0.577350, -0.577350, -0.577350, 1, 1,  0, 0, 0,
        
        -size, size, size, 0, 1, 0, 0, 2,  0, 0, 0,
        -size, size, -size, 0, 1, 0, 0, 0,  0, 0, 0,
        size, size, -size, 0, 1, 0, 2, 0,  0, 0, 0,
        size, size, size, 0, 1, 0, 2, 2,  0, 0, 0,
        
        -size, -size, -size, -0.577350, -0.577350, -0.577350, 0, 1,  0, 0, 0,
        -size, -size, size, -0.577350, -0.577350, 0.577350, 0, 0,  0, 0, 0,
        size, -size, size, 0.577350, -0.577350, 0.577350, 1, 0,  0, 0, 0,
        size, -size, -size, 0.577350, -0.577350, -0.577350, 1, 1,  0, 0, 0
    };
    
    CalculateTangent(verticesDataWithNormalAndTexCoords, sizeof(verticesDataWithNormalAndTexCoords));
    
    
    if ((m_vertexFlags & VertexFlagsNormals) && (m_vertexFlags & VertexFlagsTexCoords)) {
        memcpy(vertices, verticesDataWithNormalAndTexCoords, sizeof(verticesDataWithNormalAndTexCoords));
    } else if (m_vertexFlags & VertexFlagsNormals) {
        memcpy(vertices, verticesDataWithNormal, sizeof(verticesDataWithNormal));
    } else {
        memcpy(vertices, verticesData, sizeof(verticesData));
    }
}

void Cube::CalculateTangent(GLfloat *data, size_t dataLength) const {
    if (data == NULL) {
        return;
    }
    
    if (dataLength <= 0) {
        return;
    }
    
    struct VData
    {
        vec3 vertex;
        vec3 normal;
        vec2 uv;
        vec3 tangent;
    };
    size_t vDataLength = dataLength / sizeof(VData);
    VData *vData = (VData *)data;


    size_t indicesSize = sizeof(indicesData) / sizeof(indicesData[0]);
    for (unsigned int i = 0 ; i < indicesSize ; i += 3) {
        VData& v0 = vData[indicesData[i]];
        VData& v1 = vData[indicesData[i+1]];
        VData& v2 = vData[indicesData[i+2]];
        
        vec3 Edge1 = v1.vertex - v0.vertex;
        vec3 Edge2 = v2.vertex - v0.vertex;
        
        float DeltaU1 = v1.uv.x - v0.uv.x;
        float DeltaV1 = v1.uv.y - v0.uv.y;
        float DeltaU2 = v2.uv.x - v0.uv.x;
        float DeltaV2 = v2.uv.y - v0.uv.y;
        
        float f = 1.0f / (DeltaU1 * DeltaV2 - DeltaU2 * DeltaV1);

        vec3 Tangent;
        
        Tangent.x = f * (DeltaV2 * Edge1.x - DeltaV1 * Edge2.x);
        Tangent.y = f * (DeltaV2 * Edge1.y - DeltaV1 * Edge2.y);
        Tangent.z = f * (DeltaV2 * Edge1.z - DeltaV1 * Edge2.z);
        
        v0.tangent += Tangent;
        v1.tangent += Tangent;
        v2.tangent += Tangent;
    }
    
    for (unsigned int i = 0 ; i < vDataLength ; i++) {
        vData[i].tangent.Normalize();
    }

}

void Cube::GenerateLineIndices(unsigned short * indices) const
{
    if (!indices) {
        return;
    }
    
    const GLushort lineIndices[] = {
        // Front face
        3, 2,  2, 1,  1, 3,   /*3, 1,*/ 1, 0, 0, 3,
        
        // Back face
        7, 5,  5, 4,  4, 7,   7, 6, 6, 5, /*5, 7,*/
        
        // Left face
        /*0, 1,*/  1, 7,  7, 0,   /*7, 1,*/ 1, 6, /*6, 7,*/
        
        // Right face
        3, 4,  /*4, 5,*/  5, 3,   /*3, 5,*/ 5, 2, /*2, 3,*/
        
        // Up face
        /*1, 2,*/  /*2, 5,*/  5, 1,   /*1, 5,*/ /*5, 6,*/ /*6, 1,*/
        
        // Down face
        /*0, 7,*/  7, 3  /*,3, 0,*/   /*3, 7,*/ /*7, 4,*/ /*4, 3*/
    };
    
    memcpy(indices, lineIndices, sizeof(lineIndices));
}

void Cube::GenerateTriangleIndices(unsigned short * indices) const
{
    if (!indices) {
        return;
    }
    
    //    const GLushort indicesData[] = {
    //        // Front face
    //        3, 2, 1, 3, 1, 0,
    //
    //        // Back face
    //        7, 5, 4, 7, 6, 5,
    //
    //        // Left face
    //        0, 1, 7, 7, 1, 6,
    //
    //        // Right face
    //        3, 4, 5, 3, 5, 2,
    //
    //        // Up face
    //        1, 2, 5, 1, 5, 6,
    //
    //        // Down face
    //        0, 7, 3, 3, 7, 4
    //    };
    

    
    memcpy(indices, indicesData, sizeof(indicesData));
}

