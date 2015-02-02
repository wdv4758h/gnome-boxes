# -*- coding: UTF-8 -*-

from __future__ import unicode_literals
from behave import step

@step('Create Core-5.3 box on system broker')
def create_box_on_system_broker(context):
    context.execute_steps("""
        * Wait for "virt-install -q -r 128 --name Core-5.3 --nodisks --cdrom /tmp/Core-5.3.iso --os-type linux --accelerate --connect qemu:///system --wait 0" end
        * Wait for "sleep 10" end
        """)

@step('Import Core-5.3 box on system broker')
def import_box_on_system_broker(context):
    context.execute_steps("""
        * Wait for "virt-install -q -r 128 --name Core-5.3 --import --disk /tmp/Core-5.3.qcow2 --os-type linux --accelerate --connect qemu:///system --wait 0" end
        * Wait for "sleep 10" end
        """)

@step('Connect to system broker')
def connect_to_filled_system_broker(context):
    context.execute_steps("""
        * Create new box from url "qemu:///system"
        * Wait for "sleep 1" end
        * Press "Create"
        * Save IP for machine "Core-5.3"
        """)

@step('Connect to empty system broker')
def connect_to_empty_system_broker(context):
    context.execute_steps("""
        * Create new box from url "qemu:///system"
        * Wait for "sleep 2" end
        * Press "Create"
        """)
