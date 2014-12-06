########################################################
# The MIT License (MIT)
# Copyright (c) 2014 Mario Voorsluys (forcaeluz)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
########################################################


# Necessry files.
include("utilities.jl")

# This type contains the necessary information for a Stacked Array Piezoelectric DM.
# The parameters are based on the parameters from Yao. (From November 2014)
# The properties are:
#  - actuatorsInDiameter: The number of actuators in the diameter of the DM
#  - interActuatorDistance: The distance between actuators (mm)
#  - influenceFunction: Function to be used to compute a single actuator influence
#  - interActuatorCoupling: Coupling percentage between nearest neighboors actuators.
#  - thresholdResponse: TODO: Explain.
type PztDmConfiguration
  actuators_in_diameter::Int64
  radius::Float64
  inter_actuator_distance::Float64
  influence_function::Function
  nearest_neighbours_coupling::Float64
  diagonal_neighbours_coupling::Float64
  micron_per_volt::Float64
end

type PztDm
  configuration::PztDmConfiguration
  actuator_positions::Array
  PztDm(config::PztDmConfiguration) = initialize_stacked_array_mirror( new(config) )
end

function initialize_stacked_array_mirror(mirror::PztDm)
  actuator_positions = compute_actuator_placement(mirror.configuration)
  valid_actuators = remove_actuators_outside_mirror(actuator_positions, mirror.configuration.radius)
  mirror.actuator_positions = valid_actuators;
  return mirror
end


function compute_actuator_placement(mirror::PztDmConfiguration)
  number_act_x = mirror.actuators_in_diameter
  pitch = mirror.inter_actuator_distance
  radius = (number_act_x - 1) * pitch / 2;
  # Array with data for each actuator
  # Actuator number, x pos, y pos, distance to center
  actuator_centers = Array(Float64, number_act_x^2, 4)
  for i = 1:number_act_x, j = 1:number_act_x
    actuator_number = j + (i - 1)*number_act_x
    x_distance = (j - 1) * pitch  - radius
    y_distance = (i - 1) * pitch  - radius
    abs_distance = sqrt(x_distance^2 + y_distance ^2)
    actuator_centers[actuator_number, 1] = actuator_number
    actuator_centers[actuator_number, 2] = x_distance
    actuator_centers[actuator_number, 3] = y_distance
    actuator_centers[actuator_number, 4] = abs_distance
  end
  return actuator_centers
end


#
#
#
function remove_actuators_outside_mirror(actuator_positions, radius)
  counter::Int64 = 0
  for i = 1:size(actuator_positions)[1]
    if actuator_positions[i, 4] < radius
      counter = counter + 1
    end
  end
  filtered_actuators = Array(Float64, counter, 4)
  counter = 1
  for i = 1:size(actuator_positions)[1]
    if actuator_positions[i, 4] < radius
      filtered_actuators[counter,:] = actuator_positions[i,:]
      counter = counter + 1
    end
  end
  return filtered_actuators
end


# Reimplemented the ad-hoc function from Yao.
# Note that the influence functions compute a gain. To compute the actual
# DM shape, use the compute_shape function.
# The algorithm comes from Yao, so I refer back to it for explanation.
function compute_adhoc_influence(mirror::PztDm,
                                 actuator::Int64,
                                 read_position::Array{Float64}
                                 )
  coupling::Float64 = mirror.nearest_neighbours_coupling
  pitch::Float64 = mirror.inter_actuator_distance
  actuator_positions = mirror.actuator_positions
  returnValue::Float64 = 0
  read_x = read_position[1]
  read_y = read_position[2]
  actuator_x = actuator_positions[actuator, 2]
  actuator_y = actuator_positions[actuator, 3]
  const a1 = Float64[4.49469,7.25509,-32.1948,17.9493]
  const a2 = Float64[2.49456,-0.65952,8.78886,-6.23701]
  const a3 = Float64[1.16136,2.97422,-13.2381,20.4395]
  const p1::Float64 = a1[1] + a1[2] * coupling + a1[3] * coupling^2 + a1[4] * coupling^3
  const p2::Float64 = a2[1] + a2[2] * coupling + a2[3] * coupling^2 + a2[4] * coupling^3
  const irc::Float64 = a3[1] + a3[2] * coupling + a3[3] * coupling^2 + a3[4] * coupling^3
  const ir::Float64 = pitch * irc
  const c::Float64 = (coupling - 1 + abs(irc)^p1) / (log(abs(irc)) * abs(irc)^p2)

  tmp_x = abs((read_x - actuator_x)/ir)
  tmp_x = clip(tmp_x, 1e-8, 2)
  tmp_y = abs((read_y - actuator_y)/ir)
  tmp_y = clip(tmp_y, 1e-8, 2)
  tmp = (1 - tmp_x^p1 + c*log(tmp_x)*tmp_x^p2) * (1 - tmp_y^p1 + c*log(tmp_y)*tmp_y^p2)
  if (tmp_x <= 1) && (tmp_y <= 1)
    returnValue = tmp
  end
  return returnValue * mirror.micron_per_volt
end


# Reimplemented the ad-hoc function from Yao.
# Note that the influence functions compute a gain. To compute the actual
# DM shape, use the compute_shape function.
# The algorithm comes from Yao, so I refer back to it for explanation.
function compute_adhoc_no_coupling_influence(actuator_position, read_position, pitch)
  actuator_x = actuator_position[1]
  actuator_y = actuator_position[2]
  read_x = read_position[1]
  read_y = read_position[2]

  tmp_x = pitch - abs(read_x - actuator_x)
  tmp_y = pitch - abs(read_y - actuator_y)
  tmp = tmp_x * tmp_y
  if (tmp_x > 0) && (tmp_y > 0)
    returnValue = tmp
  end
  return returnValue;
end


# Reimplemented from the Yao sync * gaussian influence function
#
#
function compute_sync_influence(actuator_position, read_position, pitch, coupling)

end


#
#
#
function compute_gaussian_influence(actuator_position, read_position, pitch, coupling)
  const alpha::Float64 = 1.5
  x_distance = actuator_position[1] - read_position[1]
  y_distance = actuator_position[2] - read_position[2]
  distance = sqrt( x_distance^2 + y_distance^2 )
  return exp( log(coupling) * ( distance / pitch )^alpha )
end

#
#
#
function compute_double_gaussian_influence(actuator_position, read_position, pitch, coupling)

end

function compute_modified_gaussian_influence(actuator_position, read_position)

end
