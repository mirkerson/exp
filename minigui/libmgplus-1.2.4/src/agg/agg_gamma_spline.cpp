//----------------------------------------------------------------------------
// Anti-Grain Geometry (AGG) - Version 2.5
// A high quality rendering engine for C++
// Copyright (C) 2002-2006 Maxim Shemanarev
// Contact: mcseem@antigrain.com
//          mcseemagg@yahoo.com
//          http://antigrain.com
// 
// AGG is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// AGG is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with AGG; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
// MA 02110-1301, USA.
//----------------------------------------------------------------------------

#include "agg_gamma_spline.h"

namespace agg
{

    //------------------------------------------------------------------------
    gamma_spline::gamma_spline() : 
        m_x1(0), m_y1(0), m_x2(10), m_y2(10), m_cur_x(0.0)
    {
        values(1.0, 1.0, 1.0, 1.0);
    }


    //------------------------------------------------------------------------
    double gamma_spline::y(double x) const 
    { 
        if(x < 0.0) x = 0.0;
        if(x > 1.0) x = 1.0;
        double val = m_spline.get(x);
        if(val < 0.0) val = 0.0;
        if(val > 1.0) val = 1.0;
        return val;
    }



    //------------------------------------------------------------------------
    void gamma_spline::values(double kx1, double ky1, double kx2, double ky2)
    {
        if(kx1 < 0.001) kx1 = 0.001;
        if(kx1 > 1.999) kx1 = 1.999;
        if(ky1 < 0.001) ky1 = 0.001;
        if(ky1 > 1.999) ky1 = 1.999;
        if(kx2 < 0.001) kx2 = 0.001;
        if(kx2 > 1.999) kx2 = 1.999;
        if(ky2 < 0.001) ky2 = 0.001;
        if(ky2 > 1.999) ky2 = 1.999;

        m_x[0] = 0.0;
        m_y[0] = 0.0;
        m_x[1] = kx1 * 0.25;
        m_y[1] = ky1 * 0.25;
        m_x[2] = 1.0 - kx2 * 0.25;
        m_y[2] = 1.0 - ky2 * 0.25;
        m_x[3] = 1.0;
        m_y[3] = 1.0;

        m_spline.init(4, m_x, m_y);

        int i;
        for(i = 0; i < 256; i++)
        {
            m_gamma[i] = (unsigned char)(y(double(i) / 255.0) * 255.0);
        }
    }


    //------------------------------------------------------------------------
    void gamma_spline::values(double* kx1, double* ky1, double* kx2, double* ky2) const
    {
        *kx1 = m_x[1] * 4.0;
        *ky1 = m_y[1] * 4.0;
        *kx2 = (1.0 - m_x[2]) * 4.0;
        *ky2 = (1.0 - m_y[2]) * 4.0;
    }


    //------------------------------------------------------------------------
    void gamma_spline::box(double x1, double y1, double x2, double y2)
    {
        m_x1 = x1;
        m_y1 = y1;
        m_x2 = x2;
        m_y2 = y2;
    }


    //------------------------------------------------------------------------
    void gamma_spline::rewind(unsigned)
    {
        m_cur_x = 0.0;
    }


    //------------------------------------------------------------------------
    unsigned gamma_spline::vertex(double* vx, double* vy)
    {
        if(m_cur_x == 0.0) 
        {
            *vx = m_x1;
            *vy = m_y1;
            m_cur_x += 1.0 / (m_x2 - m_x1);
            return path_cmd_move_to;
        }

        if(m_cur_x > 1.0) 
        {
            return path_cmd_stop;
        }
        
        *vx = m_x1 + m_cur_x * (m_x2 - m_x1);
        *vy = m_y1 + y(m_cur_x) * (m_y2 - m_y1);

        m_cur_x += 1.0 / (m_x2 - m_x1);
        return path_cmd_line_to;
    }
  


}

