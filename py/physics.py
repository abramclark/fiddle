from math import *
try:
    import periodictable as pt # todo: add melting and boiling temps
except: pass


Av = 6.022140857e23 # # Avogadro constant
G = 6.67408e-11 # m**3 / (kg * s) # gravitational constant
c = 299792458 # m / s # speed of light
c2 = c ** 2 # m**2 / s**2
hm = 1.616199E-35 # m # planck length
hj = 6.626070040e-34 # J * s # planck constant in Joules
heV = 4.135667662e-15 # eV * s # planck constant in electron volts
R = 8.3144598 # molar, ideal, or universal gas constant
kb = R / Av # Boltzmann constant in entropy
coulomb = 6241509074460762607.776

mevtokg = 9.0958e-31 # conversion of MeV to Kg

# conversions from garbage units
ev_to_j = 1.6021766208e-19
lb_to_kg = 0.453592 # kg / pound
inch_to_m = .0254 # m / inch
feet_to_m = inch_to_m * 12 # m / feet
mi_to_km = 5280 * feet_to_m / 1e3 # 1000 * m / miles
fahrenheit_to_celsius = lambda C: (C - 32) * 5/9
celsius_to_k = lambda C: C + 273.15
fahrenheit_to_k = lambda a: celsius_to_k(fahrenheit_to_celsius(a))

# incidental constants
atm = 101325 # P # 1 atmosphere # pressure at altitude 0
solar_mass = 1.98847E30 # kg
earth_mass = 5.97237E24 # kg
earth_radius_equator = 6378137 # km
earth_radius_polar = 6356752 # km

#r J = kg * m**2 / s**2 = joules
# P = kg /( m * s**2 ) = pascals = pressure
# K = Kelvin
# acceleration = m / s**2
# m = meters
