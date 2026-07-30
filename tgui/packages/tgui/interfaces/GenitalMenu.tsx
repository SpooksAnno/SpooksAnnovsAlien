import {
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface InputData {
  cockState: string;
  cockStorage: string;
  cockDisplayState: string;
  assState: string;
  boobState: string;
  vaginaState: string;
  bellyState: string;
  testicleState: string;
  assSize: number;
  boobSize: string;
  cockSize: number;
  bellySize: number;
  testicleSize: number;
  possibleCockStates: string[];
  possibleCockStorage: string[];
  possibleCockDisplayStates: string[];
  possibleAssStates: string[];
  possibleBoobStates: string[];
  possibleVaginaStates: string[];
  possibleBellyStates: string[];
  possibleTesticleStates: string[];
  possibleBoobSizes: string[];
  layerOrder: {
    slot: string;
    rank: number;
    canMoveUp: boolean;
    canMoveDown: boolean;
  }[];
}

export const GenitalMenu = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>();
  const {
    cockState,
    cockStorage,
    cockDisplayState,
    assState,
    boobState,
    vaginaState,
    bellyState,
    testicleState,
    assSize,
    boobSize,
    cockSize,
    bellySize,
    testicleSize,
    possibleCockStates,
    possibleCockStorage,
    possibleCockDisplayStates,
    possibleAssStates,
    possibleBoobStates,
    possibleVaginaStates,
    possibleBellyStates,
    possibleTesticleStates,
    possibleBoobSizes,
    layerOrder,
  } = data;

  const layerBySlot = Object.fromEntries(
    (layerOrder || []).map((entry) => [entry.slot, entry]),
  );

  const layerButtons = (field: string) => {
    const layer = layerBySlot[field];
    return (
      <Stack ml={1}>
        <Stack.Item>
          <Button
            icon="arrow-up"
            disabled={!layer?.canMoveUp}
            tooltip="Move above nearby anatomy"
            onClick={() =>
              act('moveLayer', {
                field,
                direction: -1,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="arrow-down"
            disabled={!layer?.canMoveDown}
            tooltip="Move below nearby anatomy"
            onClick={() =>
              act('moveLayer', {
                field,
                direction: 1,
              })
            }
          />
        </Stack.Item>
      </Stack>
    );
  };

  return (
    <Window title="Genital selection" width={375} height={500}>
      <Window.Content>
        <Section>
          <Stack fill vertical>
            <Stack.Item>
              <LabeledList>
              <LabeledList.Item label="Genitalia">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleCockStates}
                      selected={cockState ? cockState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeCock', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('cock')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              {cockState && cockState !== 'Default' && cockState !== 'Human' ? (
                <LabeledList.Item label="Penis Sheath">
                  <Dropdown
                    options={possibleCockStorage}
                    selected={cockStorage ? cockStorage : 'None'}
                    onSelected={(e: string) =>
                      act('changeCockStorage', {
                        newState: e,
                      })
                    }
                  />
                </LabeledList.Item>
              ) : null}
              <LabeledList.Item label="Penis Display">
                <Dropdown
                  options={possibleCockDisplayStates}
                  selected={cockDisplayState ? cockDisplayState : 'Flaccid'}
                  onSelected={(e: string) =>
                    act('changeCockDisplayState', {
                      newState: e,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Butt">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleAssStates}
                      selected={assState ? assState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeAss', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('ass')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Butt Size">
                <NumberInput
                  value={assSize}
                  minValue={1}
                  maxValue={8}
                  step={1}
                  width="64px"
                  onChange={(value) =>
                    act('changeSize', {
                      field: 'ass',
                      newSize: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Boobs">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleBoobStates}
                      selected={boobState ? boobState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeBoobs', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('boobs')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Boob Size">
                <Dropdown
                  options={possibleBoobSizes}
                  selected={boobSize}
                  onSelected={(e: string) =>
                    act('changeSize', {
                      field: 'boobs',
                      newSize: e,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Vagina">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleVaginaStates}
                      selected={vaginaState ? vaginaState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeVagina', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('vagina')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Testicles">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleTesticleStates}
                      selected={testicleState ? testicleState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeTesticles', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('testicles')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Testicle Size">
                <NumberInput
                  value={testicleSize}
                  minValue={0}
                  maxValue={8}
                  step={1}
                  width="64px"
                  onChange={(value) =>
                    act('changeSize', {
                      field: 'testicles',
                      newSize: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Belly">
                <Stack align="center">
                  <Stack.Item grow>
                    <Dropdown
                      options={possibleBellyStates}
                      selected={bellyState ? bellyState : 'Default'}
                      onSelected={(e: string) =>
                        act('changeBelly', {
                          newState: e,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>{layerButtons('belly')}</Stack.Item>
                </Stack>
              </LabeledList.Item>
              <LabeledList.Item label="Belly Size">
                <NumberInput
                  value={bellySize}
                  minValue={0}
                  maxValue={10}
                  step={1}
                  width="64px"
                  onChange={(value) =>
                    act('changeSize', {
                      field: 'belly',
                      newSize: value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Penis Size">
                <NumberInput
                  value={cockSize}
                  minValue={1}
                  maxValue={7}
                  step={1}
                  width="64px"
                  onChange={(value) =>
                    act('changeSize', {
                      field: 'cock',
                      newSize: value,
                    })
                  }
                />
              </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                bold
                color="bad"
                icon="ban"
                fontSize={1.25}
                textAlign="center"
                onClick={() => {
                  act('reset');
                }}
              >
                Reset to default
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
