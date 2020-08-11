# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import matplotlib.pyplot as plt
import numpy
from math import log,exp

# Some specs of the messag file
trigger_phrase = 'Iteration   1:'
first_it_counter = 1
continue_phrase = 'Iteration'
pos_of_residuum = 22
length_of_residuum_word = 7
max_y = 1 # maximum for displacement norm residuum
min_y = 1e-6 # for a log-plot the ylimit cannot be zero

try:
    from IPython import get_ipython
    get_ipython().magic('clear')
    get_ipython().magic('reset -f')
except:
    pass

# init
plt.clf()   # clear the plot, needed in a new session
plt.ion()   # somehow improves the handling
plt.grid()

plt.yscale('log',basey=10)
max_y = 1
max_x = 10 # @todo make associative
min_x = first_it_counter

for i in range(-2,int(max_x)):
    xConvR = [int(min_x+i)]
    yConvR = [0.05]
    counter = 0
    for j in range(int(min_x+i),int(1.1*max_x)):
        xConvR.append(j+1)
        yConvR.append(yConvR[counter]**2)
        counter = counter+1
    plt.plot(xConvR, yConvR,'--k')

list_of_plots_data = []
with open('messag') as f:
    for line in f:
        inner_list = [elt.strip() for elt in line.split(';')]
        list_of_plots_data.append(inner_list)
        
x_block = []
y_block = []
valid_line = False

for i_line in range(0,len(list_of_plots_data)):
    valid_line = False
    if ( trigger_phrase in list_of_plots_data[i_line][0]):
        plt.plot(x_block,y_block)
        x_block = []
        y_block = []
        valid_line = True
    elif ( continue_phrase in list_of_plots_data[i_line][0]):
        valid_line = True
        
    if ( valid_line ):
        x_block.append(len(x_block)+1)
        y_block.append(float(list_of_plots_data[i_line][0][pos_of_residuum:(pos_of_residuum+length_of_residuum_word)]) )
        
plt.xticks(numpy.arange(0, max_x+1, 1.0))
        
plt.xlabel('NR iterations')
plt.ylabel('residuum |du|/|u|')

plt.axis([min_x, 1.1*max_x, 1.1*min_y, 1.1*max_y])

plt.show()