# Overview

This is a 7-people semester-long digital hardware capstone project for University of Wisconsin-Madison ECE deparment 
([ECE554/ECE901](https://guide.wisc.edu/courses/e_c_e/)).

This repository implements an out-of-order superscalar processor called Looper. Looper is a 4-issue
superscalar, out-of-order execution, 7-stage pipelined processor, with special designs inspired by
Mitchell Hayenga’s [Revolver architecture](https://ieeexplore.ieee.org/abstract/document/6835968), 
including frontend loop detection, training and dispatch, and 
multiple backend supporting schemes in issue queue, re-order buffer and load/store queue. 

See [this report](ECE901_Final_Report_LOOPERS.pdf) for design and implementation details.
