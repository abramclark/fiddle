import math
import periodictable as pt # todo: add melting and boiling temps

Av = 6.022140857e23 # # avogadro constant
G = 6.67408e-11 # m**3 / (kg * s) # gravitational constant
c = 299792458 # m / s # speed of light
c2 = c ** 2 # m**2 / s**2
hm = 1.616199E-35 # m # planck length
hj = 6.626070040e-34 # J * s # planck constant in Joules
heV = 4.135667662e-15 # eV * s # planck constant in electron volts
R = 8.3144598 # J / K
kb = R / Av # J / K # boltzman constant in entropy # 

mevtokg = 9.0958e-31 # conversion of MeV to Kg

# conversions from garbage units
lb_to_kg = 0.453592 # kg / pound
inch_to_m = .0254 # m / inch
feet_to_m = inch_to_m * 12 # m / feet
mi_to_km = 5280 * feet_to_m / 1e3 # 1000 * m / miles
Fahrenheit_to_Celsius = lambda C: (C - 32) * 5/9
Celsius_to_K = lambda C: C - 273.15
Fahrenheit_to_K = lambda a: Celsius_to_K(Fahrenheit_to_Celsius(a))

atm = 101325 # P # 1 atmosphere # pressure at altitude 0

# J = kg * m**2 / s**2 = joules = energy
# P = J / m**3 = pascals = pressure
# K = Kelvin
# Fahrenheit2K * Fahrenheit = K
# acceleration = m / s**2
# m = meters = unit(x)
