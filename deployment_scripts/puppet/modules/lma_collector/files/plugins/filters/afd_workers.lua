-- Copyright 2015 Mirantis, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

require 'string'

local afd = require 'afd'
local consts = require 'gse_constants'

local worker_states = {}

-- emit AFD event metrics based on openstack_nova_services, openstack_cinder_services and openstack_neutron_agents metrics
function process_message()
    local metric_name = read_message('Fields[name]')
    local service = string.format('%s-%s',
                                  string.match(metric_name, 'openstack_([^_]+)'),
                                  read_message('Fields[service]'))
    local worker_key = string.format('%s.%s', metric_name, service)

    if not worker_states[worker_key] then
        worker_states[worker_key] = {up=0, down=0}
    end
    local worker = worker_states[worker_key]
    worker[read_message('Fields[state]')] = read_message('Fields[value]')

    local state = consts.OKAY
    if worker.up == 0 and worker.down == 0 then
        -- not enough data for now
        return 0
    elseif worker.up == 0 then
        state = consts.DOWN
        afd.add_to_alarms(consts.DOWN,
                          'last',
                          string.format("%s[service=%s,state=up]", metric_name, service),
                          '==',
                          0,
                          nil,
                          nil,
                          string.format("All instances for service %s are down or disabled", service))
    elseif worker.down >= worker.up then
        state = consts.CRIT
        afd.add_to_alarms(consts.CRIT,
                          'last',
                          string.format("%s[service=%s,state=down]", metric_name, service),
                          '>=',
                          worker.up,
                          nil,
                          nil,
                          string.format("The number of down instances for the service %s is greater than or equal to the number of up instances", service))
    elseif worker.down > 0 then
        state = consts.WARN
        afd.add_to_alarms(consts.WARN,
                          'last',
                          string.format("%s[service=%s,state=down]", metric_name, service),
                          '>',
                          0,
                          nil,
                          nil,
                          string.format("%d instance(s) of the service %s is/are down", worker.down, service))
    end

    afd.inject_afd_service_event(service, state, 0, 'afd_workers')
    return 0
end
