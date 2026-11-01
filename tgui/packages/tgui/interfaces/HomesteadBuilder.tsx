import { useState } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Stat = { key: string; name: string };
type Skill = { type: string; name: string };
type SkillCategory = { name: string; skills: Skill[] };
type Perk = {
  type: string;
  name: string;
  desc: string | null;
  cost: number;
  category: string;
};
type Kit = { type: string; name: string };

type Data = {
  enabled: BooleanLike;
  stat_points: number;
  stat_min: number;
  stat_max: number;
  stat_max_gain: number;
  skill_points: number;
  perk_points: number;
  expertise_points: number;
  expertise_category: string;
  max_kits: number;
  level_names: string[];
  stats: Stat[];
  skill_categories: SkillCategory[];
  perks: Perk[];
  kits: Kit[];
  stat_values: Record<string, number>;
  skill_levels: Record<string, number>;
  skill_caps: Record<string, number>;
  skill_costs: Record<string, number[]>;
  selected_perks: string[];
  selected_kits: string[];
  stat_spent: number;
  stat_gain: number;
  skill_spent: number;
  perk_spent: number;
  expertise_spent: number;
  problems: string[];
  notes: string[];
};

enum Tab {
  Stats,
  Skills,
  Expertise,
  Perks,
  Kits,
}

export const HomesteadBuilder = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState(Tab.Skills);

  return (
    <Window title="Homesteader Build" width={640} height={680}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Budget"
              buttons={
                <>
                  <Button.Checkbox
                    checked={data.enabled}
                    onClick={() => act('toggle_enabled')}
                  >
                    Use custom build
                  </Button.Checkbox>
                  <Button icon="undo" onClick={() => act('reset')}>
                    Reset
                  </Button>
                </>
              }
            >
              <Stack>
                <Stack.Item grow>
                  Stats: {data.stat_spent}/{data.stat_points} (bonuses{' '}
                  {data.stat_gain}/{data.stat_max_gain})
                </Stack.Item>
                <Stack.Item grow>
                  Skills: {data.skill_spent}/{data.skill_points}
                </Stack.Item>
                <Stack.Item grow>
                  Expertise: {data.expertise_spent}/{data.expertise_points}
                </Stack.Item>
                <Stack.Item grow>
                  Perks: {data.perk_spent}/{data.perk_points}
                </Stack.Item>
                <Stack.Item grow>
                  Kits: {data.selected_kits.length}/{data.max_kits}
                </Stack.Item>
              </Stack>
              {!data.enabled && (
                <Box mt={1} color="label">
                  Disabled: you spawn as the regular jack-of-all-trades
                  Homesteader.
                </Box>
              )}
              <Box mt={1} color="label" italic>
                Save your character to keep changes.
              </Box>
            </Section>
          </Stack.Item>
          {data.problems.length > 0 && (
            <Stack.Item>
              <NoticeBox danger>{data.problems.join(' ')}</NoticeBox>
            </Stack.Item>
          )}
          {data.notes.length > 0 && (
            <Stack.Item>
              <NoticeBox>{data.notes.join(' ')}</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === Tab.Stats}
                onClick={() => setTab(Tab.Stats)}
              >
                Stats
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Skills}
                onClick={() => setTab(Tab.Skills)}
              >
                Skills
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Expertise}
                onClick={() => setTab(Tab.Expertise)}
              >
                Expertise
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Perks}
                onClick={() => setTab(Tab.Perks)}
              >
                Perks
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Kits}
                onClick={() => setTab(Tab.Kits)}
              >
                Kits
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Stats && <StatsTab />}
            {tab === Tab.Skills && <SkillsTab />}
            {tab === Tab.Expertise && <ExpertiseTab />}
            {tab === Tab.Perks && <PerksTab />}
            {tab === Tab.Kits && <KitsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StatsTab = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Section fill scrollable>
      <Table>
        {data.stats.map((stat) => {
          const value = data.stat_values[stat.key] || 0;
          return (
            <Table.Row key={stat.key} className="candystripe">
              <Table.Cell>{stat.name}</Table.Cell>
              <Table.Cell collapsing textAlign="center">
                <Button
                  icon="minus"
                  disabled={value <= data.stat_min}
                  onClick={() =>
                    act('set_stat', { stat: stat.key, value: value - 1 })
                  }
                />
                <Box inline width="2em" textAlign="center">
                  {value > 0 ? `+${value}` : value}
                </Box>
                <Button
                  icon="plus"
                  disabled={
                    value >= data.stat_max ||
                    data.stat_spent >= data.stat_points ||
                    (value >= 0 && data.stat_gain >= data.stat_max_gain)
                  }
                  onClick={() =>
                    act('set_stat', { stat: stat.key, value: value + 1 })
                  }
                />
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const SkillsTab = () => {
  const { data } = useBackend<Data>();

  return (
    <Section fill scrollable>
      {data.skill_categories.map((category) => (
        <SkillTable
          key={category.name}
          title={category.name}
          skills={category.skills}
        />
      ))}
    </Section>
  );
};

const SkillTable = (props: { title: string; skills: Skill[] }) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title={props.title}>
      <Table>
        {props.skills.map((skill) => {
          const level = data.skill_levels[skill.type] || 0;
          const cap = data.skill_caps[skill.type] || 0;
          const costs = data.skill_costs[skill.type] || [];
          const nextCost = (costs[level + 1] ?? 0) - (costs[level] ?? 0);
          const canRaise =
            level < cap && data.skill_spent + nextCost <= data.skill_points;
          return (
            <Table.Row key={skill.type} className="candystripe">
              <Table.Cell>{skill.name}</Table.Cell>
              <Table.Cell collapsing color="label">
                {cap > 0 ? `cap ${data.level_names[cap]}` : 'needs a perk'}
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                <Button
                  icon="minus"
                  disabled={level <= 0}
                  onClick={() =>
                    act('set_skill', { skill: skill.type, level: level - 1 })
                  }
                />
                <Box inline width="7em" textAlign="center">
                  {data.level_names[level]}
                </Box>
                <Button
                  icon="plus"
                  disabled={!canRaise}
                  tooltip={level < cap ? `Costs ${nextCost}` : undefined}
                  onClick={() =>
                    act('set_skill', { skill: skill.type, level: level + 1 })
                  }
                />
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const ExpertiseTab = () => {
  const { data } = useBackend<Data>();

  return (
    <Section fill scrollable>
      <PerkTable
        title={data.expertise_category}
        perks={data.perks.filter(
          (perk) => perk.category === data.expertise_category,
        )}
        spent={data.expertise_spent}
        points={data.expertise_points}
      />
    </Section>
  );
};

const PerksTab = () => {
  const { data } = useBackend<Data>();
  const categories = Array.from(
    new Set(data.perks.map((perk) => perk.category)),
  ).filter((category) => category !== data.expertise_category);

  return (
    <Section fill scrollable>
      {categories.map((category) => (
        <PerkTable
          key={category}
          title={category}
          perks={data.perks.filter((perk) => perk.category === category)}
          spent={data.perk_spent}
          points={data.perk_points}
        />
      ))}
    </Section>
  );
};

const PerkTable = (props: {
  title: string;
  perks: Perk[];
  spent: number;
  points: number;
}) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title={props.title}>
      <Table>
        {props.perks.map((perk) => {
          const selected = data.selected_perks.includes(perk.type);
          return (
            <Table.Row key={perk.type} className="candystripe">
              <Table.Cell collapsing>
                <Button.Checkbox
                  checked={selected}
                  disabled={!selected && props.spent + perk.cost > props.points}
                  onClick={() => act('toggle_perk', { perk: perk.type })}
                >
                  {perk.name}
                </Button.Checkbox>
              </Table.Cell>
              <Table.Cell collapsing textAlign="center">
                {perk.cost}
              </Table.Cell>
              <Table.Cell color="label">{perk.desc}</Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const KitsTab = () => {
  const { act, data } = useBackend<Data>();

  return (
    <Section fill scrollable>
      {data.kits.map((kit) => {
        const selected = data.selected_kits.includes(kit.type);
        return (
          <Box key={kit.type} mb={0.5}>
            <Button.Checkbox
              checked={selected}
              disabled={!selected && data.selected_kits.length >= data.max_kits}
              onClick={() => act('toggle_kit', { kit: kit.type })}
            >
              {kit.name}
            </Button.Checkbox>
          </Box>
        );
      })}
    </Section>
  );
};
