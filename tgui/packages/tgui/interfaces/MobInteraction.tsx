import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SexAction = {
  name: string;
  ref: string;
  enabled: boolean;
  active: boolean;
  color?: string;
  disabledReason?: string | null;
  sortOrder?: number;
};

type GenitalField = {
  id: string;
  label: string;
  value: string;
  options?: string[];
  size?: number;
  sizeOptions?: string[];
  min?: number;
  max?: number;
};

type GenitalControl = {
  slot: string;
  name: string;
  active: boolean;
  visibility: string;
  alwaysAccessible: boolean;
  canArouse: boolean;
  aroused: number;
  layer: number;
};

type MobInteractionData = {
  targetName: string;
  isTargetSelf: boolean;
  arousal: number;
  targetArousal: number;
  maxArousal: number;
  speed: string;
  force: string;
  drainStyle: string;
  manualArousal: string;
  doUntilFinished: boolean;
  showUnavailableParts: boolean;
  allowKnotting: boolean;
  isTargetAdjacent: boolean;
  currentAction: string | null;
  knotLockStatus: string | null;
  canUseManualArousal: boolean;
  actions: SexAction[];
  genitals: GenitalField[];
  genitalControls: GenitalControl[];
  cockStorageVisible: boolean;
};

const GENITAL_VISIBILITY_NEVER = 'never';
const GENITAL_VISIBILITY_CLOTHED = 'clothed';
const GENITAL_VISIBILITY_ALWAYS = 'always';

const AROUSAL_NONE = 1;
const AROUSAL_PARTIAL = 2;
const AROUSAL_FULL = 3;

export const MobInteraction = (_props: any) => {
  const { act, data } = useBackend<MobInteractionData>();
  const {
    targetName,
    isTargetSelf,
    arousal,
    targetArousal,
    maxArousal,
    speed,
    force,
    drainStyle,
    manualArousal,
    doUntilFinished,
    showUnavailableParts,
    allowKnotting,
    isTargetAdjacent,
    currentAction,
    knotLockStatus,
    canUseManualArousal,
    actions = [],
    genitals = [],
    genitalControls = [],
    cockStorageVisible,
  } = data;
  const [tabIndex, setTabIndex] = useState(0);
  const [searchText, setSearchText] = useState('');

  const filteredActions = actions
    .map((actionEntry, index) => ({ actionEntry, index }))
    .filter(({ actionEntry }) =>
      actionEntry.name.toLowerCase().includes(searchText.toLowerCase()),
    )
    .sort(
      (left, right) =>
        (left.actionEntry.sortOrder ?? 50) -
          (right.actionEntry.sortOrder ?? 50) || left.index - right.index,
    )
    .map(({ actionEntry }) => actionEntry);
  const filteredGenitals = genitals.filter(
    (field) =>
      field.label.toLowerCase().includes(searchText.toLowerCase()) &&
      (cockStorageVisible || field.id !== 'cockStorage'),
  );
  const filteredGenitalControls = genitalControls.filter((field) =>
    field.name.toLowerCase().includes(searchText.toLowerCase()),
  );
  const maxGenitalLayer = Math.max(
    0,
    ...genitalControls.map((field) => field.layer || 0),
  );

  return (
    <Window width={520} height={660} title="Mob Interaction">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title={isTargetSelf ? 'Self Interaction' : targetName}>
              <Stack vertical>
                <Stack.Item>
                  <ProgressBar value={arousal} maxValue={maxArousal} color="pink">
                    <Icon name="heart" /> Your Arousal
                  </ProgressBar>
                </Stack.Item>
                {!isTargetSelf && (
                  <Stack.Item>
                    <ProgressBar
                      value={targetArousal}
                      maxValue={maxArousal}
                      color="purple"
                    >
                      <Icon name="heart" /> Their Arousal
                    </ProgressBar>
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack vertical>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <ControlPair label="Speed" value={speed} action="speed" />
                    </Stack.Item>
                    <Stack.Item grow>
                      <ControlPair label="Force" value={force} action="force" />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <ControlPair
                        label="Drain"
                        value={drainStyle}
                        action="drain_style"
                      />
                    </Stack.Item>
                    {canUseManualArousal && (
                      <Stack.Item grow>
                        <ControlPair
                          label="Arousal"
                          value={manualArousal}
                          action="manual_arousal"
                        />
                      </Stack.Item>
                    )}
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon={doUntilFinished ? 'flag-checkered' : 'infinity'}
                        selected={doUntilFinished}
                        onClick={() => act('toggle_finished')}
                      >
                        {doUntilFinished ? 'Until Finished' : 'Until Stopped'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="stop"
                        color="red"
                        disabled={!currentAction}
                        onClick={() => act('stop')}
                      >
                        Stop
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                {!!knotLockStatus && (
                  <Stack.Item>
                    <Box color="orange">
                      <Icon name="link" /> {knotLockStatus}
                    </Box>
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon={showUnavailableParts ? 'eye' : 'eye-slash'}
                        selected={showUnavailableParts}
                        onClick={() => act('toggle_unavailable_parts')}
                      >
                        {showUnavailableParts
                          ? 'Showing Missing Parts'
                          : 'Hiding Missing Parts'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="link"
                        selected={allowKnotting}
                        onClick={() => act('toggle_knotting')}
                      >
                        {allowKnotting ? 'Knotting Enabled' : 'Knotting Disabled'}
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
                Interactions
              </Tabs.Tab>
              <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
                Visibility
              </Tabs.Tab>
              <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
                Genital Options
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>
                <Icon name="search" />
              </Stack.Item>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder={
                    tabIndex === 0
                      ? 'Search for an interaction'
                      : tabIndex === 1
                        ? 'Search for visibility controls'
                        : 'Search for a genital option'
                  }
                  value={searchText}
                  onChange={(value) => setSearchText(value)}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section fill scrollable>
              {tabIndex === 0 ? (
                <Stack vertical>
                  {filteredActions.map((actionEntry) => (
                    <Stack.Item key={actionEntry.ref}>
                      <Button
                        fluid
                        icon={actionEntry.active ? 'stop' : 'play'}
                        selected={actionEntry.active}
                        color={
                          actionEntry.active
                            ? 'green'
                            : actionEntry.color || 'pink'
                        }
                        disabled={!actionEntry.enabled && !actionEntry.active}
                        tooltip={
                          !actionEntry.enabled && !actionEntry.active
                            ? actionEntry.disabledReason || 'Unavailable'
                            : undefined
                        }
                        onClick={() =>
                          act('action', { action_type: actionEntry.ref })
                        }
                      >
                        {actionEntry.name}
                      </Button>
                    </Stack.Item>
                  ))}
                  {!isTargetAdjacent && filteredActions.length === 0 && (
                    <Stack.Item>
                      <Box color="label">Move closer to see nearby interactions.</Box>
                    </Stack.Item>
                  )}
                </Stack>
              ) : tabIndex === 1 ? (
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      {filteredGenitalControls.map((genital) => (
                        <LabeledList.Item
                          key={genital.slot}
                          label={genital.name}
                          color={genital.active ? undefined : 'grey'}
                        >
                          <Stack justify="flex-end">
                            <Stack.Item>
                              <Button
                                icon="arrow-up"
                                disabled={genital.layer <= 1}
                                tooltip="Move above nearby anatomy"
                                onClick={() =>
                                  act('move_genital_layer', {
                                    genital: genital.slot,
                                    direction: -1,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="arrow-down"
                                disabled={genital.layer >= maxGenitalLayer}
                                tooltip="Move below nearby anatomy"
                                onClick={() =>
                                  act('move_genital_layer', {
                                    genital: genital.slot,
                                    direction: 1,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon={
                                  genital.alwaysAccessible
                                    ? 'lock-open'
                                    : 'lock'
                                }
                                color={
                                  genital.alwaysAccessible
                                    ? 'good'
                                    : 'default'
                                }
                                tooltip={
                                  genital.alwaysAccessible
                                    ? 'Can be accessed through clothes'
                                    : 'Normal clothing rules'
                                }
                                onClick={() =>
                                  act('toggle_genital_accessibility', {
                                    genital: genital.slot,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="eye"
                                selected={
                                  genital.visibility ===
                                  GENITAL_VISIBILITY_ALWAYS
                                }
                                tooltip="Always display"
                                onClick={() =>
                                  act('toggle_genital_visibility', {
                                    genital: genital.slot,
                                    visibility: GENITAL_VISIBILITY_ALWAYS,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="eye-low-vision"
                                selected={
                                  genital.visibility ===
                                  GENITAL_VISIBILITY_CLOTHED
                                }
                                tooltip="Display with clothes ruling"
                                onClick={() =>
                                  act('toggle_genital_visibility', {
                                    genital: genital.slot,
                                    visibility: GENITAL_VISIBILITY_CLOTHED,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon="eye-slash"
                                selected={
                                  genital.visibility ===
                                  GENITAL_VISIBILITY_NEVER
                                }
                                tooltip="Never display"
                                onClick={() =>
                                  act('toggle_genital_visibility', {
                                    genital: genital.slot,
                                    visibility: GENITAL_VISIBILITY_NEVER,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                icon={
                                  genital.canArouse
                                    ? genital.aroused === AROUSAL_NONE
                                      ? 'heart'
                                      : genital.aroused === AROUSAL_PARTIAL
                                        ? 'heartbeat'
                                        : 'heart-circle-bolt'
                                    : 'times'
                                }
                                color={
                                  !genital.canArouse
                                    ? 'grey'
                                    : genital.aroused === AROUSAL_NONE
                                      ? 'red'
                                      : genital.aroused === AROUSAL_PARTIAL
                                        ? 'good'
                                        : 'pink'
                                }
                                disabled={!genital.canArouse}
                                tooltip={
                                  genital.canArouse
                                    ? genital.aroused === AROUSAL_NONE
                                      ? 'Set penis display to unaroused or stored.'
                                      : genital.aroused === AROUSAL_PARTIAL
                                        ? 'Set penis display to flaccid.'
                                        : 'Set penis display to erect.'
                                    : 'This part has no arousal state.'
                                }
                                onClick={() =>
                                  act('toggle_genital_arousal', {
                                    genital: genital.slot,
                                    arousal:
                                      genital.aroused === AROUSAL_NONE
                                        ? AROUSAL_PARTIAL
                                        : genital.aroused === AROUSAL_PARTIAL
                                          ? AROUSAL_FULL
                                          : AROUSAL_NONE,
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      {filteredGenitals.map((field) => (
                        <LabeledList.Item key={field.id} label={field.label}>
                          {field.options ? (
                            <Dropdown
                              options={field.options}
                              selected={field.value}
                              onSelected={(value: string) =>
                                act('genital_dropdown', {
                                  field: field.id,
                                  value,
                                })
                              }
                            />
                          ) : field.sizeOptions ? (
                            <Dropdown
                              options={field.sizeOptions}
                              selected={field.value}
                              onSelected={(value: string) =>
                                act('genital_size', {
                                  field: field.id,
                                  value,
                                })
                              }
                            />
                          ) : (
                            <NumberInput
                              value={field.size || 0}
                              minValue={field.min || 0}
                              maxValue={field.max || 10}
                              step={1}
                              width="64px"
                              onChange={(value) =>
                                act('genital_size', {
                                  field: field.id,
                                  value,
                                })
                              }
                            />
                          )}
                        </LabeledList.Item>
                      ))}
                      <LabeledList.Item label="Reset">
                        <Button
                          fluid
                          icon="ban"
                          color="bad"
                          onClick={() => act('genital_reset')}
                        >
                          Reset to default
                        </Button>
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ControlPair = (props: {
  label: string;
  value: string;
  action: string;
}) => {
  const { act } = useBackend();

  return (
    <Stack align="center">
      <Stack.Item>
        <Button icon="chevron-left" onClick={() => act(`${props.action}_down`)} />
      </Stack.Item>
      <Stack.Item grow textAlign="center">
        {props.label}: {props.value}
      </Stack.Item>
      <Stack.Item>
        <Button icon="chevron-right" onClick={() => act(`${props.action}_up`)} />
      </Stack.Item>
    </Stack>
  );
};
