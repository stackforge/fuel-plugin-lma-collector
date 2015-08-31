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

require('luaunit')
package.path = package.path .. ";files/plugins/common/?.lua" 
local gse = require('gse')
local consts = require('gse_constants')

-- configure relations and dependencies
gse.level_1_dependency("keystone", "keystone_admin")
gse.level_1_dependency("keystone", "keystone_main")
gse.level_1_dependency("neutron", "neutron_api")
gse.level_1_dependency("nova", "nova_api")
gse.level_1_dependency("nova", "nova_ec2_api")
gse.level_1_dependency("nova", "nova_scheduler")
gse.level_1_dependency("glance", "glance_api")
gse.level_1_dependency("glance", "glance_registry")

gse.level_2_dependency("nova_api", "neutron_api")
gse.level_2_dependency("nova_scheduler", "rabbitmq")

-- provision facts
gse.set_status("keystone_admin", consts.OKAY, {})
gse.set_status("neutron_api", consts.DOWN, {{message="All neutron endpoints are down"}})
gse.set_status("nova_api", consts.OKAY, {})
gse.set_status("nova_ec2_api", consts.OKAY, {})
gse.set_status("nova_scheduler", consts.OKAY, {})
gse.set_status("rabbitmq", consts.WARN, {{message="1 RabbitMQ node out of 3 is down"}})
gse.set_status("glance_api", consts.WARN, {{message="glance-api endpoint is down on node-1"}})
gse.set_status("glance_registry", consts.DOWN, {{message='glance-registry endpoints are down'}})

TestGse = {}

    function TestGse:test_keystone_is_okay()
        local status, alarms_1, alarms_2 = gse.resolve_status('keystone')
        assertEquals(status, consts.OKAY)
        assertEquals(#alarms_1, 0)
        assertEquals(#alarms_2, 0)
    end

    function TestGse:test_cinder_is_unknow()
        local status, alarms_1, alarms_2 = gse.resolve_status('cinder')
        assertEquals(status, consts.UNKW)
        assertEquals(#alarms_1, 0)
        assertEquals(#alarms_2, 0)
    end

    function TestGse:test_neutron_is_down()
        local status, alarms_1, alarms_2 = gse.resolve_status('neutron')
        assertEquals(status, consts.DOWN)
        assertEquals(#alarms_1, 1)
        assertEquals(#alarms_2, 0)
    end

    function TestGse:test_nova_is_critical()
        local status, alarms_1, alarms_2 = gse.resolve_status('nova')
        assertEquals(status, consts.CRIT)
        assertEquals(#alarms_1, 0)
        assertEquals(#alarms_2, 1)
    end

    function TestGse:test_glance_is_down()
        local status, alarms_1, alarms_2 = gse.resolve_status('glance')
        assertEquals(status, consts.DOWN)
        assertEquals(#alarms_1, 2)
        assertEquals(#alarms_2, 0)
    end

lu = LuaUnit
lu:setVerbosity( 1 )
os.exit( lu:run() )
