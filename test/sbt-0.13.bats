#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "0.13.1"
  echo "sbt.version=0.13.1" > "$sbt_project/project/build.properties"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done'
}

@test "successes to set trace level for sbt 0.13.x" {
  stub_java
  run sbt -trace 1
  assert_success
  { java_options <<EOS
-jar
${HOME}/.sbt/launchers/0.13.1/sbt-launch.jar
set every traceLevel := 1
shell
EOS
  } | assert_output
  unstub java
}

@test "not enables default sbt.global.base for 0.13.x" {
  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-jar
${HOME}/.sbt/launchers/0.13.1/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables special sbt.global.base for 0.13.x if -sbt-dir was given" {
  stub_java
  run sbt -sbt-dir "${sbt_project}/sbt.base"
  assert_success
  { java_options <<EOS
-Dsbt.global.base=${sbt_project}/sbt.base
-jar
${HOME}/.sbt/launchers/0.13.1/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}
