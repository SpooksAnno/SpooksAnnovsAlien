import { useState } from 'react';
import { Box, Button, Input, LabeledList, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SelectFieldPreference, TextFieldPreference } from './FieldPreferences';

const EditableTextSection = ({
  title,
  value,
  original,
  action,
  param,
  onChange,
  height = '110px',
  maxLength = 12000,
}) => {
  const { act } = useBackend<BackgroundInformationData>();

  return (
    <Section
      title={title}
      buttons={
        <Box>
          <Button
            icon="save"
            disabled={value === original}
            onClick={() => act(action, { [param]: value })}
          >
            Save
          </Button>
          <Button icon="times" onClick={() => onChange(original)}>
            Reset
          </Button>
        </Box>
      }
    >
      <TextArea
        expensive
        fluid
        height={height}
        maxLength={maxLength}
        value={value}
        onChange={onChange}
      />
    </Section>
  );
};

const PictureSection = ({
  title,
  value,
  original,
  action,
  param,
  onChange,
}) => {
  const { act } = useBackend<BackgroundInformationData>();

  return (
    <Section
      title={title}
      buttons={
        <Box>
          <Button
            icon="save"
            disabled={value === original}
            onClick={() => act(action, { [param]: value })}
          >
            Save
          </Button>
          <Button icon="times" onClick={() => onChange(original)}>
            Reset
          </Button>
        </Box>
      }
    >
      <TextArea
        expensive
        fluid
        height="72px"
        maxLength={2048}
        value={value}
        onChange={onChange}
      />
      {original ? (
        <Box mt={1} textAlign="center">
          <img src={original} width={180} height={210} />
        </Box>
      ) : null}
    </Section>
  );
};

export const BackgroundInformation = (props) => {
  const { act, data } = useBackend<BackgroundInformationData>();
  const {
    custom_species_name,
    flavor_text,
    med_record,
    gen_record,
    sec_record,
    exploit_record,
    xeno_desc,
    profile_pic,
    nsfwprofile_pic,
    xenoprofile_pic,
    metadata,
    metadata_favs,
    metadata_likes,
    metadata_maybes,
    metadata_dislikes,
    metadata_ooc_style,
  } = data;

  const [characterDesc, setCharacterDesc] = useState(flavor_text);
  const [medicalDesc, setMedicalDesc] = useState(med_record);
  const [employmentDesc, setEmploymentDesc] = useState(gen_record);
  const [securityDesc, setSecurityDesc] = useState(sec_record);
  const [exploitsDesc, setExploitsDesc] = useState(exploit_record);
  const [xenoDesc, setXenoDesc] = useState(xeno_desc);
  const [profilePic, setProfilePic] = useState(profile_pic);
  const [nsfwprofilePic, setNSFWProfilePic] = useState(nsfwprofile_pic);
  const [xenoprofilePic, setXenoProfilePic] = useState(xenoprofile_pic);
  const [oocNotes, setOocNotes] = useState(metadata);
  const [oocFavs, setOocFavs] = useState(metadata_favs);
  const [oocLikes, setOocLikes] = useState(metadata_likes);
  const [oocMaybes, setOocMaybes] = useState(metadata_maybes);
  const [oocDislikes, setOocDislikes] = useState(metadata_dislikes);

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Identity">
          <LabeledList>
            <TextFieldPreference label="Age" value="age" />
            <LabeledList.Item label="Custom Species">
              <Input
                placeholder="Use mechanical species"
                value={custom_species_name || ''}
                onBlur={(newValue) =>
                  act('custom_species_name', { newValue })
                }
              />
            </LabeledList.Item>
            <SelectFieldPreference
              label="Citizenship"
              value="citizenship"
              action="citizenship"
            />
            <SelectFieldPreference
              label="Religion"
              value="religion"
              action="religion"
            />
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <EditableTextSection
              title="Character Description"
              value={characterDesc}
              original={flavor_text}
              action="flavor_text"
              param="characterDesc"
              onChange={setCharacterDesc}
              height="170px"
            />
          </Stack.Item>
          <Stack.Item grow>
            <EditableTextSection
              title="Xenomorph Description"
              value={xenoDesc}
              original={xeno_desc}
              action="xeno_desc"
              param="xenoDesc"
              onChange={setXenoDesc}
              height="170px"
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item>
        <Section
          title="OOC Notes"
          buttons={
            <Button.Checkbox
              checked={metadata_ooc_style}
              onClick={() => act('metadata_ooc_style')}
            >
              OOC Styling
            </Button.Checkbox>
          }
        >
          <EditableTextSection
            title="General Notes"
            value={oocNotes}
            original={metadata}
            action="metadata"
            param="oocNotes"
            onChange={setOocNotes}
            height="120px"
          />
          <Stack>
            <Stack.Item grow>
              <EditableTextSection
                title="Favourites"
                value={oocFavs}
                original={metadata_favs}
                action="metadata_favs"
                param="oocFavs"
                onChange={setOocFavs}
                height="82px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <EditableTextSection
                title="Likes"
                value={oocLikes}
                original={metadata_likes}
                action="metadata_likes"
                param="oocLikes"
                onChange={setOocLikes}
                height="82px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <EditableTextSection
                title="Maybes"
                value={oocMaybes}
                original={metadata_maybes}
                action="metadata_maybes"
                param="oocMaybes"
                onChange={setOocMaybes}
                height="82px"
              />
            </Stack.Item>
            <Stack.Item grow>
              <EditableTextSection
                title="Dislikes"
                value={oocDislikes}
                original={metadata_dislikes}
                action="metadata_dislikes"
                param="oocDislikes"
                onChange={setOocDislikes}
                height="82px"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Records">
          <Stack>
            <Stack.Item grow>
              <EditableTextSection
                title="Medical"
                value={medicalDesc}
                original={med_record}
                action="med_record"
                param="medicalDesc"
                onChange={setMedicalDesc}
                height="90px"
                maxLength={1024}
              />
            </Stack.Item>
            <Stack.Item grow>
              <EditableTextSection
                title="Employment"
                value={employmentDesc}
                original={gen_record}
                action="gen_record"
                param="employmentDesc"
                onChange={setEmploymentDesc}
                height="90px"
                maxLength={1024}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item grow>
              <EditableTextSection
                title="Security"
                value={securityDesc}
                original={sec_record}
                action="sec_record"
                param="securityDesc"
                onChange={setSecurityDesc}
                height="90px"
                maxLength={1024}
              />
            </Stack.Item>
            <Stack.Item grow>
              <EditableTextSection
                title="Exploits"
                value={exploitsDesc}
                original={exploit_record}
                action="exploit_record"
                param="exploitsDesc"
                onChange={setExploitsDesc}
                height="90px"
                maxLength={1024}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <PictureSection
              title="Human Picture"
              value={profilePic}
              original={profile_pic}
              action="profile_pic"
              param="profilePic"
              onChange={setProfilePic}
            />
          </Stack.Item>
          <Stack.Item grow>
            <PictureSection
              title="Human Nude Picture"
              value={nsfwprofilePic}
              original={nsfwprofile_pic}
              action="nsfwprofile_pic"
              param="nsfwprofilePic"
              onChange={setNSFWProfilePic}
            />
          </Stack.Item>
          <Stack.Item grow>
            <PictureSection
              title="Xeno Picture"
              value={xenoprofilePic}
              original={xenoprofile_pic}
              action="xenoprofile_pic"
              param="xenoprofilePic"
              onChange={setXenoProfilePic}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
