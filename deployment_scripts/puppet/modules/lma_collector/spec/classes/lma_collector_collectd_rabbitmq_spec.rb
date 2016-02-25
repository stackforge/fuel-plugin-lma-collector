#    Copyright 2016 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
require 'spec_helper'

describe 'lma_collector::collectd::rabbitmq' do
    let(:facts) do
        {:kernel => 'Linux', :operatingsystem => 'Ubuntu',
         :osfamily => 'Debian', :concat_basedir => '/foo'}
    end

    describe 'with defaults' do
        it { is_expected.to contain_lma_collector__collectd__python('rabbitmq_info') }
    end

    describe 'with regex queue matching' do
        let(:params) do
            {:regex_queue_match => '^(foo|bar)\w+$'}
        end
        it { is_expected.to contain_lma_collector__collectd__python('rabbitmq_info') \
             .with_config({'RegexQueueMatch' => '"^(foo|bar)\\\\w+$"'})
        }
    end
end
