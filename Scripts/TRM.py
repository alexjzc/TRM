import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import yfinance as yf

# %% Símbolo para la TRM en Yahoo Finance
symbol = 'COP=X'

# Descargar datos históricos de la TRM
trm_data = yf.download(symbol, start='2018-05-01', end='2023-05-18')

# Preliminares
db = trm_data['Close']
db2 = db.div(db.sum(), axis=0)

variaciones = db2.iloc[1:].div(db2.iloc[:-1].values) - 1

# Simulación Cartera B
X0 = db.iloc[-1]
simulaciones = np.empty((10000, 7))

for i in range(10000):
    simulaciones[i, 0] = X0 * np.exp(np.mean(variaciones) - np.var(variaciones) / 2 + np.std(variaciones) * np.random.normal(1))
    for j in range(1, 7):
        simulaciones[i, j] = simulaciones[i, j-1] * np.exp(np.mean(variaciones) - np.var(variaciones) / 2 + np.std(variaciones) * np.random.normal(1))

plt.plot(simulaciones.T)
plt.show()

# Cuantil al 99%
quantiles_99 = np.quantile(simulaciones, 1 - 0.01, axis=0)
print(quantiles_99)

# Cuantil al 95%
quantiles_95 = np.quantile(simulaciones, 1 - 0.05, axis=0)
print(quantiles_95)

# Cuantil al 90%
quantiles_90 = np.quantile(simulaciones, 1 - 0.1, axis=0)
print(quantiles_90)

# Cuantil al 50%
quantiles_50 = np.quantile(simulaciones, 1 - 0.5, axis=0)
print(quantiles_50)
