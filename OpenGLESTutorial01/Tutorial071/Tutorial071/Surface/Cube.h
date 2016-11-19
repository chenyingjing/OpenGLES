//
//  Cube.hpp
//  Tutorial06
//
//  Created by aa64mac on 13/11/2016.
//  Copyright © 2016 cyj. All rights reserved.
//

#ifndef Cube_hpp
#define Cube_hpp

#include <stdio.h>
#include "ParametricSurface.h"

class Cube : public ISurface {
public:
    void SetVertexFlags(unsigned char flags = 0);
    
    int GetVertexSize() const;
    int GetVertexCount() const;
    int GetLineIndexCount() const;
    int GetTriangleIndexCount() const;
    
    void GenerateVertices(float * vertices) const;
    void GenerateLineIndices(unsigned short * indices) const;
    void GenerateTriangleIndices(unsigned short * indices) const;

};



#endif /* Cube_hpp */
