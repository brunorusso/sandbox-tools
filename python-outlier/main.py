%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt

incomes = np.random.normal(1000, 200, 10000)
incomes = np.append(incomes, [1000000000000000])  # Adding an outlier
import matplotlib.pyplot as plt
plt.hist(incomes, 50)
plt.show()
